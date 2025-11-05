#!/bin/bash
#SBATCH --mail-user=mh105@iu.edu
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:30:00
#SBATCH --mem=8G
#SBATCH -J neg2pheno
#SBATCH -o /N/slate/mh105/tools/neg2pheno/records/log/neg2pheno_%j.out
#SBATCH -e /N/slate/mh105/tools/neg2pheno/records/log/neg2pheno_%j.out
#SBATCH -A r00269
#SBATCH --array=1

set -euo pipefail

NEG2PHENO_ENV=myenv

RAW_IN="/N/slate/mh105/tools/neg2pheno/records/input"
OUT_DIR="/N/slate/mh105/tools/neg2pheno/records/output"
HPO="/N/slate/mh105/tools/neg2pheno/ref/hpo/hp.obo"
PHENOBERT_UTILS="/N/slate/mh105/scripts/PhenoBERT/phenobert/utils"

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
  --termset en_clinical \
  --model en_core_web_sm \
  --txt_mode lines \
  --phenobert_root /N/slate/mh105/scripts/PhenoBERT \
  -t 8

