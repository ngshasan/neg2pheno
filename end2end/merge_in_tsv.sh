#!/bin/env bash

# ✅ Can run directly on the login node

# 2.1) Combine all per-file outputs into one TSV with a header and file name in .txt

#OUT=/N/scratch/mh105/phenobert/output
#printf "file\tstart\tend\tphrase\tHPO_ID\tconfidence\n" > "$OUT/phenobert_merged.tsv"

#for f in "$OUT"/*.txt; do
#  [[ -s "$f" ]] || continue          # skip empty
#  awk -v fname="$(basename "$f")" -v OFS='\t' '
#    NF>=5 {print fname,$1,$2,$3,$4,$5}
#  ' "$f" >> "$OUT/phenobert_merged.tsv"
#done


# 2.2) Merge all the output hpo file in .txt in a combined  tsv without .txt in the patinet file name

OUT=/N/slate/mh105/tools/neg2pheno/hpo_out
printf "file\tstart\tend\tphrase\tHPO_ID\tconfidence\n" > "$OUT/phenobert_merged.tsv"

for f in "$OUT"/*.txt; do
  [[ -s "$f" ]] || continue   # skip empty files
  base=$(basename "$f" .txt)  # remove .txt extension
  awk -v fname="$base" -v OFS='\t' '
    NF>=5 {print fname,$1,$2,$3,$4,$5}
  ' "$f" >> "$OUT/phenobert_merged.tsv"
done

echo "✅ Merged TSV written to $OUT/phenobert_merged.tsv"

