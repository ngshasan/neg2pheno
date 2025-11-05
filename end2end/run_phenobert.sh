#!/bin/env bash

# Always run this on an Interactive node, not on the login node.

#srun --partition=general \
#     --nodes=1 \
#     --cpus-per-task=8 \
#     --mem=16G \
#     --time=02:00:00 \
#     --account=r00269 \
#     --job-name=phenobert \
#     --pty bash -l

module purge
module load gnu/12.2.0
module load sqlite/3.35.5
source ~/miniconda3/etc/profile.d/conda.sh
conda activate myenv

cd /N/slate/mh105/scripts/PhenoBERT/phenobert/utils
export NLTK_DATA=/N/u/$USER/Quartz/nltk_data
export OMP_NUM_THREADS=8 MKL_NUM_THREADS=8

# run phenobert

python annotate.py \
  -i /N/scratch/$USER/phenobert/input_txt \
  -o /N/scratch/$USER/phenobert/output_txt \
  -t 8

#python annotate.py \
#  -i /N/scratch/$USER/phenobert/input \
#  -o /N/scratch/$USER/phenobert/output \
#  -t 8
