#!/bin/bash

# Option 2: Merge both into a single new environment (neg2pheno)
# We can combine all dependencies into one conda env (simpler to use, but heavier).

conda create -y -n neg2pheno python=3.10
conda activate neg2pheno

# Core NLP + extraction
pip install "numpy<2.0" pandas==2.2.2 spacy==3.7.5 negspacy==1.0.4 pronto==2.5.6

# PhenoBERT + ML stack
pip install torch==2.2.2 --index-url https://download.pytorch.org/whl/cpu
pip install stanza==1.5.0 nltk==3.9.1 fasttext==0.9.2 scikit-learn==1.4.2 tqdm==4.66.4

# Model setup
python -m spacy download en_core_web_sm
python -m nltk.downloader punkt averaged_perceptron_tagger
python -c "import stanza; stanza.download('en')"


# 9: Then everything (A, B, or C) runs in the same environment:

conda activate neg2pheno
neg2pheno \
  --in_dir /N/slate/mh105/scripts/negspacy/input \
  --out_dir /N/slate/mh105/scripts/negspacy/output \
  --hp_obo /N/slate/mh105/ref/hpo/hp.obo \
  --phenobert_root /N/slate/mh105/scripts/PhenoBERT/phenobert/utils \
  -t 8


✅ Pros:

One command, one environment.

Works seamlessly with your CLI.

⚠️ Cons:

Slightly larger env (~3–4 GB).

If PyTorch or spaCy ever upgrade their NumPy bindings differently, you may need to pin versions again

🧠 My recommendation (for your HPC workflow)

Stick with Option 1 (two environments) for now — it’s safer and cleaner for cluster use.
Once the CLI (neg2pheno) is finalized and tested, we can build a conda environment spec (environment.yml) that merges both cleanly for local or laptop use.
