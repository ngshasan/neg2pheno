## neg2pheno
---

### 🧬 neg2pheno

**neg2pheno** is a unified command-line toolkit that connects **NegEx-based phenotype extraction** (via NegSpacy) and **HPO annotation** (via PhenoBERT).  
It processes clinical text, removes negated or uncertain phenotypes, maps to **HPO terms**, and produces clean text files ready for analysis.

---

### 🚀 Features

- Detect **affirmed** phenotypic terms from raw text using NegSpacy  
- Automatically exclude **negated** or **uncertain** mentions (NegEx algorithm)  
- Map terms to **HPO ontology** (`hp.obo`)  
- Export `.txt` output directly compatible with **PhenoBERT**  
- Run **both stages (NegEx + PhenoBERT)** with a single command  
- Fully HPC-compatible (Quartz / BigRed clusters)

---

### ⚙️ Installation (HPC-Safe Conda Build Method)

The following steps describe how to build and install `neg2pheno` cleanly in your own Slate directories.  
This avoids permission issues on shared systems.

```bash
# 1. Load Conda and prepare build tools
source ~/miniconda3/etc/profile.d/conda.sh
conda activate base
conda install -y -c conda-forge conda-build conda-verify

# 2. Configure personal Conda paths
conda config --add pkgs_dirs /N/slate/$USER/conda_pkgs
conda config --set conda_build.root_dir /N/slate/$USER/conda_bld

# 3. Build the package
RECIPE=/N/slate/$USER/tools/neg2pheno/conda
conda build "$RECIPE"

# 4. Get the exact artifact path
PKG=$(conda build "$RECIPE" --output)
echo $PKG   # should print something like:
# /N/slate/$USER/conda_bld/noarch/neg2pheno-0.1.0-py_0.tar.bz2

# 5. Install into both environments (negex and myenv)
conda activate negex
conda install -y "$PKG"

conda activate myenv
conda install -y "$PKG"

### Check installation

```bash
negspacy-extract
phenobert-annotate
neg2pheno
```

### Check availability:

```bash
which negspacy-extract
neg2pheno -h
```

### Example Usage

#### 1) NegEx Extraction Only

```bash
negspacy-extract \
  --in_dir /N/slate/$USER/scripts/negspacy/input \
  --out_dir /N/slate/$USER/scripts/negspacy/output \
  --hp_obo /N/slate/$USER/ref/hpo/hp.obo \
  --termset en_clinical \
  --model en_core_web_sm
```

#### Output

```swift
/N/slate/$USER/scripts/negspacy/output/negex/ALL.hpo_mentions.txt
/N/slate/$USER/scripts/negspacy/output/negex/ALL.hpo_affirmed.txt
```

#### 2) PhenoBERT Annotation Only

```bash
phenobert-annotate \
  --in_dir /N/slate/$USER/scripts/negspacy/output/negex \
  --out_dir /N/slate/$USER/scripts/negspacy/output/phenobert \
  --phenobert_root /N/slate/$USER/scripts/PhenoBERT/phenobert/utils \
  -t 8
```

#### Output

```pgsql
phenobert_output.txt
phenobert_output.json
```

### 3) Full Pipeline (NegEx → PhenoBERT)

```bash
module purge
module load gnu/12.2.0
module load sqlite/3.35.5
source ~/miniconda3/etc/profile.d/conda.sh
conda activate myenv

neg2pheno \
  --in_dir /N/slate/$USER/scripts/negspacy/input \
  --out_dir /N/slate/$USER/scripts/negspacy/output \
  --hp_obo /N/slate/$USER/ref/hpo/hp.obo \
  --termset en_clinical \
  --model en_core_web_sm \
  --txt_mode lines \
  --phenobert_root /N/slate/$USER/scripts/PhenoBERT \
  -t 8
```

#### Output structure:

```css
output/
├── negex/
│   ├── ALL.hpo_mentions.txt
│   └── ALL.hpo_affirmed.txt
└── phenobert/
    └── phenobert_output.txt
```

### Download hp.obo (if not present)

```bash
mkdir -p /N/slate/$USER/ref/hpo
wget -O /N/slate/$USER/ref/hpo/hp.obo https://purl.obolibrary.org/obo/hp.obo
```

### 🧾 Citation

Hasan, M. (2025). neg2pheno: Automated NegEx and HPO Annotation Pipeline for Clinical Texts.

### 🪪 License

Licensed under the MIT License

### 💻 Author

- **Mehadi Hasan**  
  Bioinformatics Scientist  
  Indiana University School of Medicine  
  Indianapolis, Indiana, United States


### 🔗 GitHub: ngshasan

```yaml
Would you like me to add a short **“build_neg2pheno.sh”** helper script (one-click version of your full conda build + install process)? It’ll make future updates as easy as `bash build_neg2pheno.sh`.
```
