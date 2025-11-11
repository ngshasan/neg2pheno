#!/usr/bin/env python3
"""
NegEx + HPO extraction → TXT (for PhenoBERT)
- Reads .txt notes from --in_dir
- Matches HPO names/synonyms (from --hpo_tsv or --hp_obo)
- Applies NegEx, keeps affirmed only
- Writes per-file TXT into out_dir/<txt_subdir> (default: out_dir/in)
- Optional: emits JSON (--emit_json) with {id, text}

Env (example):
  conda create -y -n negex python=3.10
  conda activate negex
  python -m pip install "numpy<2.0" spacy==3.7.5 negspacy==1.0.4 pandas
  python -m spacy download en_core_web_sm
  # If using --hp_obo:
  # python -m pip install pronto
"""

import argparse, json, re, sys
from pathlib import Path
from typing import Iterable
import pandas as pd
import spacy
from spacy.language import Language
from spacy.matcher import PhraseMatcher
from spacy.tokens import Doc, Span

# negspacy
try:
    from negspacy.negation import Negex
    from negspacy.termsets import termset
except Exception:
    print("ERROR: negspacy not found. Install via: pip install negspacy", file=sys.stderr)
    raise

# pronto (optional)
try:
    import pronto
    HAS_PRONTO = True
except Exception:
    HAS_PRONTO = False


def load_hpo_from_tsv(tsv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(tsv_path, sep="\t", dtype=str).fillna("")
    need = {"HPO_ID", "name", "synonym"}
    if not need.issubset(df.columns):
        raise ValueError(f"TSV must have columns {sorted(need)}; found {df.columns.tolist()}")
    return df


def load_hpo_from_obo(obo_path: Path) -> pd.DataFrame:
    if not HAS_PRONTO:
        raise RuntimeError("pronto not installed. Run: pip install pronto")
    ont = pronto.Ontology(str(obo_path))
    rows = []
    for term in ont.terms():
        if not term.id.startswith("HP:"):
            continue
        name = (term.name or "").strip()
        syn_texts = set([name]) if name else set()
        for s in getattr(term, "synonyms", []):
            text = getattr(s, "description", None) or getattr(s, "desc", None) or str(s)
            if text:
                text = text.strip()
                if text:
                    syn_texts.add(text)
        for syn in syn_texts:
            rows.append({"HPO_ID": term.id, "name": name, "synonym": syn})
    df = pd.DataFrame(rows).fillna("")
    print(f"Loaded {len(df)} HPO synonym entries from {obo_path}")
    return df


@Language.factory("hpo_spans", default_config={"terms": []})
def make_hpo_spans(nlp, name, terms: Iterable[str]):
    matcher = PhraseMatcher(nlp.vocab, attr="LOWER")
    batch = []
    for t in terms:
        t = (t or "").strip()
        if not t:
            continue
        batch.append(nlp.make_doc(t))
        if len(batch) == 1000:
            matcher.add("HPO_TERM", batch)
            batch = []
    if batch:
        matcher.add("HPO_TERM", batch)
    nlp.vocab.strings.add("HPO")

    def component(doc: Doc) -> Doc:
        spans = [Span(doc, s, e, label=nlp.vocab.strings["HPO"]) for _, s, e in matcher(doc)]
        doc.ents = tuple(spacy.util.filter_spans(spans))  # replace ents with HPO-only
        return doc

    return component


def _sanitize_filename(name: str) -> str:
    base = (name or "note").split("/")[-1].split("\\")[-1].strip()
    base = re.sub(r"[^A-Za-z0-9._-]+", "_", base)
    if not base.lower().endswith(".txt"):
        base += ".txt"
    return base


def write_txt_bundle(out_dir: Path, affirmed_map: dict, mode: str, subdir: str) -> Path:
    txt_dir = out_dir / subdir
    txt_dir.mkdir(parents=True, exist_ok=True)
    for fname, mentions in affirmed_map.items():
        safe = _sanitize_filename(fname)
        terms = sorted({(m or "").strip() for m in mentions if (m or "").strip()})
        if mode == "semicolons":
            content = "; ".join(terms) + ("\n" if terms else "")
        else:
            content = "\n".join(terms) + ("\n" if terms else "")
        (txt_dir / safe).write_text(content, encoding="utf-8")
    return txt_dir


def run_pipeline(nlp, in_dir: Path, out_dir: Path, hpo_df: pd.DataFrame) -> dict:
    """Return affirmed_map: {filename -> [affirmed_mentions,...]}"""
    out_dir.mkdir(parents=True, exist_ok=True)
    terms = list(hpo_df["synonym"].astype(str).unique())

    names = [n for n, _ in nlp.pipeline]
    try:
        names.index("negex")
        nlp.add_pipe("hpo_spans", config={"terms": terms}, before="negex")
    except ValueError:
        nlp.add_pipe("hpo_spans", config={"terms": terms}, last=True)
        print("WARNING: NegEx not found yet; added hpo_spans at end.", file=sys.stderr)

    affirmed_map = {}
    for p in sorted(in_dir.glob("*.txt")):
        text = p.read_text(encoding="utf-8", errors="ignore")
        doc = nlp(text)
        affirmed = []
        for ent in doc.ents:
            if ent.label_ == "HPO" and not bool(getattr(ent._, "negex", False)):
                affirmed.append(ent.text)
        affirmed_map[p.name] = affirmed
    return affirmed_map


def main():
    ap = argparse.ArgumentParser(description="HPO extraction with NegEx → TXT")
    ap.add_argument("--in_dir", required=True, type=Path, help="Directory of input .txt notes")
    ap.add_argument("--out_dir", required=True, type=Path, help="Output directory")
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--hpo_tsv", type=Path, help="TSV columns: HPO_ID, name, synonym")
    g.add_argument("--hp_obo", type=Path, help="Path to hp.obo (requires pronto)")
    ap.add_argument("--model", default="en_core_web_sm", help="spaCy model")
    ap.add_argument("--termset", default="en_clinical",
                    choices=["en_clinical", "en_clinical_sensitive"], help="NegEx termset")
    ap.add_argument("--max_length", type=int, default=2_000_000, help="spaCy max_length")
    # TXT / JSON controls
    ap.add_argument("--emit_txt", action="store_true", default=True,
                    help="Write per-file TXT with affirmed terms (default: on)")
    ap.add_argument("--txt_mode", choices=["lines", "semicolons"], default="lines",
                    help="TXT format: 'lines' (default) or 'semicolons'")
    ap.add_argument("--txt_subdir", default="in", help="Subdir under out_dir for TXT files")
    ap.add_argument("--emit_json", action="store_true", help="Also write JSON {id,text}")
    ap.add_argument("--json_filename", default="text_examples.json", help="JSON filename")
    args = ap.parse_args()

    nlp = spacy.load(args.model)
    nlp.max_length = args.max_length
    ts = termset(args.termset)
    nlp.add_pipe("negex", config={"ent_types": ["HPO"], "neg_termset": ts.get_patterns()}, last=True)

    hpo_df = load_hpo_from_tsv(args.hpo_tsv) if args.hpo_tsv else load_hpo_from_obo(args.hp_obo)

    affirmed_map = run_pipeline(nlp, args.in_dir, args.out_dir, hpo_df)

    if args.emit_txt:
        txt_dir = write_txt_bundle(args.out_dir, affirmed_map, mode=args.txt_mode, subdir=args.txt_subdir)
        print(f"Wrote TXT inputs for PhenoBERT: {txt_dir}")

    if args.emit_json:
        entries = []
        for fname, mentions in affirmed_map.items():
            text_field = "; ".join(sorted({m.strip() for m in mentions if m}))
            entries.append({"id": fname, "text": text_field})
        out_path = Path(args.out_dir) / args.json_filename
        out_path.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"Wrote JSON for PhenoBERT: {out_path}")

    print(f"Done. Results written to: {args.out_dir}")


if __name__ == "__main__":
    main()



