#!/bin/bash

set -euo pipefail

NEG2PHENO_ENV=myenv

RAW_IN="/N/slate/mh105/tools/neg2pheno/records/input"
OUT_DIR="/N/slate/mh105/tools/neg2pheno/records/output"
HPO="/N/slate/mh105/tools/neg2pheno/ref/hpo/hp.obo"
PHENOBERT_UTILS="/N/slate/mh105/scripts/PhenoBERT/phenobert/utils"

# conda 
module purge
module load gnu/12.2.0
module load sqlite/3.35.5
source ~/miniconda3/etc/profile.d/conda.sh
conda activate $NEG2PHENO_ENV

# run neg2hpo
neg2pheno \
  --in_dir "$RAW_IN" \
  --out_dir "$OUT_DIR" \
  --hp_obo "$HPO" \
  --phenobert_root "$PHENOBERT_UTILS" \ 
  --termset en_clinical \
  --model en_core_web_sm \
  --txt_mode lines \
  -t 8


