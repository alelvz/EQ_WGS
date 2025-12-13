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
  --jobs 200 \
  --jobname "{rule}-{wildcards.sample,jobid}-{jobid}" \
  --use-conda \
  --conda-prefix conda_envs \
  --configfile config/config.yml \
  --rerun-incomplete \
  --default-resources mem_mb=10000 runtime=720 threads=1 \
  --latency-wait 60 \
  --keep-going \
  --printshellcmds \
  -s binning.smk
