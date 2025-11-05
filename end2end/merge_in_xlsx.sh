#!/usr/bin/env bash
# drop -u to avoid unbound vars in conda activate/deactivate hooks
set -eo pipefail

# ✅ Run on an interactive node (or as a small batch job)
# ❌ Don’t run directly on the login node

module purge
module load gnu/12.2.0
module load sqlite/3.35.5

# conda setup
source ~/miniconda3/etc/profile.d/conda.sh

# pre-bind env vars some hooks expect
export JAVA_LD_LIBRARY_PATH="${JAVA_LD_LIBRARY_PATH-}"
export xml_catalog_files_libxml2="${xml_catalog_files_libxml2-}"

conda activate myenv

# Run

OUT="/N/slate/mh105/tools/neg2pheno/hpo_out"

mkdir -p "$OUT"

echo "[INFO] Merging PhenoBERT .txt outputs from: $OUT"

python - <<'PY'
import pandas as pd, glob, os

out = f"/N/scratch/{os.getenv('USER')}/phenobert/output_txt"
files = sorted(glob.glob(f"{out}/*.txt"))

rows = []
for f in files:
    with open(f, encoding="utf-8") as fh:
        for line in fh:
            parts = line.strip().split("\t")
            if len(parts) == 5:
                rows.append([os.path.basename(f), *parts])

if rows:
    df = pd.DataFrame(rows, columns=["file", "start", "end", "phrase", "HPO_ID", "confidence"])
    xlsx_path = f"{out}/phenobert_merged.xlsx"
    df.to_excel(xlsx_path, index=False)
    print(f"✅ Wrote: {xlsx_path} ({len(df)} rows)")
else:
    print(f"⚠️ No valid rows found in: {out}")
PY

echo "[DONE] Merge complete."



# [INFO] Merging PhenoBERT .txt outputs from: /N/scratch/mh105/phenobert/outputi_txt
# ✅ Wrote: /N/scratch/mh105/phenobert/output/phenobert_merged.xlsx (132 rows)
# [DONE] Merge complete.

