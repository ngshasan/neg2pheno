# 9) Quick end-to-end examples

A. Extract TXT only

negspacy-extract \
  --in_dir /N/slate/mh105/tools/neg2pheno/records/input \
  --out_dir /N/slate/mh105/tools/neg2pheno/records/output \
  --hp_obo /N/slate/mh105/tools/neg2pheno/ref/hpo/hp.obo \
  --termset en_clinical \
  --emit_txt --txt_mode lines --txt_subdir txt_in


B. Annotate
phenobert-annotate \
  --phenobert_root /N/slate/mh105/scripts/PhenoBERT/phenobert/utils \
  -i /N/slate/mh105/tools/neg2pheno/records/output/txt_in \
  -o /N/slate/mh105/tools/neg2pheno/hpo_out \
  -t 8

C. One-shot

neg2pheno \
  --in_dir /N/slate/mh105/tools/neg2pheno/records/input \
  --out_dir /N/slate/mh105/tools/neg2pheno/records/output \
  --hp_obo /N/slate/mh105/tools/neg2pheno/ref/hpo/hp.obo \
  --phenobert_root /N/slate/mh105/scripts/PhenoBERT/phenobert/utils \
  -t 8
