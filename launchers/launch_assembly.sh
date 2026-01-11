#!/bin/bash -l

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
