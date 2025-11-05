#!/bin/bash
# neg2pheno_hpc.sh

NEGEX_ENV=negex
PHENOBERT_ENV=myenv

RAW_IN="/N/slate/mh105/tools/neg2pheno/records/input"
OUT_DIR="/N/slate/mh105/tools/neg2pheno/records/output"
HPO="/N/slate/mh105/tools/neg2pheno/ref/hpo/hp.obo"
PHENOBERT_UTILS="/N/slate/mh105/scripts/PhenoBERT/phenobert/utils"

module purge
module load gnu/12.2.0
module load sqlite/3.35.5
source ~/miniconda3/etc/profile.d/conda.sh

# Step 1: run NegEx in its own env

conda activate $NEGEX_ENV

negspacy-extract \
  --in_dir "$RAW_IN" \
  --out_dir "$OUT_DIR" \
  --hp_obo "$HPO" \
  --termset en_clinical \
  --emit_txt --txt_mode lines --txt_subdir negspacy_in

# Step 2: switch to PhenoBERT env

conda activate $PHENOBERT_ENV

phenobert-annotate \
  --phenobert_root "$PHENOBERT_UTILS" \
  -i "$OUT_DIR/negspacy_in" \
  -o "$OUT_DIR/phenobert_out" \
  -t 8


# bash neg2pheno_hpc.sh
# Pros:
# Keeps each env clean and minimal (no package conflicts).
# HPC-safe (no risk of ABI issues between PyTorch and spaCy).
# Cons:
# Slightly slower to activate/deactivate conda between steps.
