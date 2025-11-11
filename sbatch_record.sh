#!/bin/bash

### save job file in a simple way
# echo -e "6421944\tdownload_BaseSpace_project_data.sh" >> jobs.txt

### automate saving job information after each sbatch submission

script_name=$1
if [[ -z "$script_name" ]]; then
    echo "Usage: bash jobs_record.sh <script_name>"
    exit 1
fi

job_id=$(sbatch "$script_name" | awk '{print $4}')
echo -e "${job_id}\t${script_name}" >> jobs.txt

## usage:
# chmod +x jobs_record.sh 
# run: ./sbatch_record.sh download_BaseSpace_project_data.sh

# check the job in shell
# seff 6423641
