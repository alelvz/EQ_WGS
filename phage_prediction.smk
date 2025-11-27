import os
from glob import glob
import pandas as pd

# Define config
CONFIG = os.environ.get("config_file", "")
configfile: CONFIG

env_dir = config["env_dir"]
src_dir = config["src_dir"]

# Load sample metadata table
assembly_table = pd.read_csv(config["assembly_table"], sep="\t")
phage_contigs = pd.read_csv(config["phage_contigs"], sep="\t")

# Create a dictionary mapping sample → assembly path
assembly_dict = {
    row["sample"]: row["Prokaryotes_fasta"]
    for _, row in assembly_table.iterrows()
}

# Create a dictionary mapping sample → phage_contigs path
phage_dict = {
    row["sample"]: row["phage_fasta"]
    for _, row in phage_contigs.iterrows()
}

# List of samples for rule expansion
#samples = list(assembly_table["sample"])
samples = list(phage_contigs["sample"])

phages_dir = config['phages_dir']


# Rules
include: 'rules/phages/genomad.rule'
include: 'rules/phages/phamer.rule'
include: 'rules/phages/virsorter2.rule'
include: 'rules/phages/plasme.rule'
#include: 'rules/phages/merge.rule'
#include: 'rules/phages/phage_contigs.rule'
#include: 'rules/phages/phabox2.rule'


workdir: phages_dir

rule all:
    input:
        expand("genomad/{sample}/genomad.done", sample = samples),
        expand("phabox/{sample}/phabox.done", sample = samples),
        expand("virsorter/{sample}/virsorter.done", sample = samples),
        expand("plasme/{sample}/plasme.done", sample = samples),
#        expand("summary/{sample}_pred_analysis.tsv", sample = samples),
#        expand("phage_contigs/{sample}_phage_contigs.fa", sample = samples),
#        expand("phabox/{sample}/phabox.done", sample = samples)
