#!/bin/bash -l
#SBATCH --time 24:00:00
#SBATCH --job-name=cat
#SBATCH --mail-type=fail
#SBATCH --ntasks 4
#SBATCH --cpus-per-task 6
#SBATCH --mem=384

conda activate snakemake

#snakemake -s taxonomy_annotation.smk --configfile ../config/config.yml --unlock
#snakemake --use-conda -s taxonomy_annotation.smk --configfile ../config/config.yml --rerun-incomplete

snakemake \
  --executor slurm \
  --jobs 75 \
  --jobname "{rule}-{wildcards.sample,jobid}-{jobid}" \
  --use-conda \
  --configfile config/config.yml \
  --rerun-incomplete \
  --default-resources mem_mb=4000 runtime=3600 threads=1 \
  --latency-wait 60 \
  --keep-going \
  -s binning.smk
