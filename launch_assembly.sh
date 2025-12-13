#!/bin/bash -l
#SBATCH --time 24:00:00
#SBATCH --job-name=cat
#SBATCH --mail-type=fail
#SBATCH --ntasks 4
#SBATCH --cpus-per-task 6
#SBATCH --mem=64



snakemake \
  --executor slurm \
  --jobs 100 \
  --default-resources \
      slurm_partition=batch \
      mem_mb=8000 \
      runtime=240 \
      threads=1 \
  --use-conda \
  --conda-prefix conda_envs \
  --configfile config/config.yml \
  --rerun-incomplete \
  --latency-wait 60 \
  --keep-going \
  --printshellcmds \
  -s assembly.smk


  # --conda-frontend mamba \