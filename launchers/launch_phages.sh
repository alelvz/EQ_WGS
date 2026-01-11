#!/bin/bash -l

snakemake \
  --executor slurm \
  --jobs 200 \
  --jobname "{rule}-{wildcards.sample,jobid}-{jobid}" \
  --use-conda \
  --conda-prefix conda_envs \
  --configfile config/config.yml \
  --rerun-incomplete \
  --default-resources mem_mb=10000 runtime=3600 threads=1 \
  --latency-wait 60 \
  --keep-going \
  --printshellcmds \
  -s phage_prediction.smk
