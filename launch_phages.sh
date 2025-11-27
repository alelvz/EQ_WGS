#!/bin/bash -l

conda activate snakemake

snakemake \
  --executor slurm \
  --jobs 100 \
  --jobname "{rule}-{wildcards.sample,jobid}-{jobid}" \
  --use-conda \
  --configfile config/config.yml \
  --rerun-incomplete \
  --default-resources mem_mb=4000 runtime=3600 threads=1 \
  --latency-wait 120 \
  --keep-going \
  -s phage_prediction.smk

#  --conda-prefix conda_envs \