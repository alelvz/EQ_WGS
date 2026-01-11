#!/usr/bin/env python3
"""
Phage prediction workflow for Empty Quarter metagenomes.

Runs multiple phage prediction tools:
- geNomad: Neural network-based virus/plasmid detection
- VIBRANT: Virus identification by iterating through BLAST
- VirSorter2: Machine learning virus detection
- PHAMER: Transformer-based phage identification
- PlasMe: Deep learning plasmid detection

Author: Alejandra Lopez-Velazquez
Date: January 2025
"""
import os
from glob import glob
import pandas as pd

# Define config
CONFIG = os.environ.get("config_file", "")
configfile: CONFIG

env_dir = config["env_dir"]
#src_dir = config["src_dir"]

# Load sample metadata table
samples_table = pd.read_csv(config["samples_table"], sep="\t")

# Create a dictionary mapping sample → prokaryotic fasta path
prokaryotes_dict = {
    row["sample"]: row["Prokaryotes_fasta"]
    for _, row in samples_table.iterrows()
}

# List of samples for rule expansion
samples = list(samples_table["sample"])

phages_dir = config['phages_dir']


# Rules
include: 'rules/phages/genomad.rule'
include: 'rules/phages/vibrant.rule'
include: 'rules/phages/virsorter2.rule'
include: 'rules/phages/phamer.rule'
include: 'rules/phages/plasme.rule'
#include: 'rules/phages/merge.rule'
#include: 'rules/phages/phage_contigs.rule'
#include: 'rules/phages/phabox2.rule'

workdir: phages_dir

rule all:
    input:
        expand("prediction/{sample}/genomad/genomad.done", sample=samples),
        expand("prediction/{sample}/vibrant/vibrant.done", sample=samples),
        expand("prediction/{sample}/virsorter2/virsorter.done", sample=samples),
        expand("prediction/{sample}/phamer/phamer.done", sample=samples),
        expand("prediction/{sample}/plasme/plasme.done", sample=samples)
#        expand("{sample}/phabox/phabox.done", sample=samples),
#        expand("{sample}/summary/pred_analysis.tsv", sample=samples),
#        expand("{sample}/phage_contigs/phage_contigs.fa", sample=samples),

