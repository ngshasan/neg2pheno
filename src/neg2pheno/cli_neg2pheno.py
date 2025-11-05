import os
import sys
import subprocess
import argparse

def main():
    ap = argparse.ArgumentParser(description="NegEx→TXT→PhenoBERT one-shot pipeline")
    # extract args
    ap.add_argument("--in_dir", required=True)
    ap.add_argument("--out_dir", required=True)
    group = ap.add_mutually_exclusive_group(required=True)
    group.add_argument("--hpo_tsv")
    group.add_argument("--hp_obo")
    ap.add_argument("--termset", default="en_clinical", choices=["en_clinical", "en_clinical_sensitive"])
    ap.add_argument("--model", default="en_core_web_sm")
    ap.add_argument("--txt_mode", default="lines", choices=["lines", "semicolons"])
    ap.add_argument("--txt_subdir", default="in")

    # phenobert args
    ap.add_argument("--phenobert_root", default=os.environ.get("PHENOBERT_ROOT", ""))
    ap.add_argument("-t", "--threads", type=int, default=8)

    args, unknown = ap.parse_known_args()

    # 1) extract
    extract_cmd = [
        "negspacy-extract",
        "--in_dir", args.in_dir,
        "--out_dir", args.out_dir,
        "--termset", args.termset,
        "--model", args.model,
        "--emit_txt", "--txt_mode", args.txt_mode, "--txt_subdir", args.txt_subdir
    ]
    if args.hp_obo:
        extract_cmd += ["--hp_obo", args.hp_obo]
    else:
        extract_cmd += ["--hpo_tsv", args.hpo_tsv]

    print(">> Running:", " ".join(extract_cmd), flush=True)
    subprocess.check_call(extract_cmd)

    # 2) annotate
    in_txt = os.path.join(args.out_dir, args.txt_subdir)
    annot_cmd = [
        "phenobert-annotate",
        "--phenobert_root", args.phenobert_root,
        "-i", in_txt,
        "-o", os.path.join(args.out_dir, "phenobert_out"),
        "-t", str(args.threads)
    ] + list(unknown)

    print(">> Running:", " ".join(annot_cmd), flush=True)
    subprocess.check_call(annot_cmd)

    print("All done.")

