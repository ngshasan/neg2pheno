import os
import sys
import argparse
import runpy

def main():
    ap = argparse.ArgumentParser(description="Run PhenoBERT annotate.py")
    ap.add_argument("-i", "--in_dir", required=True, help="Folder of .txt notes (one per patient)")
    ap.add_argument("-o", "--out_dir", required=True, help="Output folder")
    ap.add_argument("-t", "--threads", type=int, default=8)
    ap.add_argument("--phenobert_root", default=os.environ.get("PHENOBERT_ROOT", ""),
                    help="Path to PhenoBERT/phenobert/utils (where annotate.py lives)")
    args, unknown = ap.parse_known_args()

    if not args.phenobert_root:
        sys.exit("Set --phenobert_root or PHENOBERT_ROOT to PhenoBERT/phenobert/utils")

    ann_path = os.path.join(args.phenobert_root, "annotate.py")
    if not os.path.exists(ann_path):
        sys.exit(f"annotate.py not found at {ann_path}")

    # Build sys.argv for annotate.py
    sys.argv = [
        "annotate.py",
        "-i", args.in_dir,
        "-o", args.out_dir,
        "-t", str(args.threads),
    ] + unknown

    # Ensure NLTK data path can be set via env
    os.environ.setdefault("NLTK_DATA", os.path.expanduser(f"~/nltk_data"))

    runpy.run_path(ann_path, run_name="__main__")

