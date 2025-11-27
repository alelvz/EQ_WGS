import os
from glob import glob
import pandas as pd

# Define config
CONFIG = os.environ.get("config_file", "")
configfile: CONFIG

env_dir = config["env_dir"]
src_dir = config["src_dir"]

# Load sample metadata table
samples_table = pd.read_csv(config["samples_table"], sep="\t")

# Create a dictionary mapping sample → reads path
reads_dict = {
    row["sample"]: {"r1": row["R1_raw"], "r2": row["R2_raw"]}
    for _, row in samples_table.iterrows()
}

# List of samples for rule expansion
samples = list(reads_dict.keys()) 
config["samples"] = reads_dict

output_dir = config['project_dir']
project_dir = config['project_dir']

# Rules
include: 'rules/assembly/qc.rule'
include: 'rules/assembly/assembly.rule'

ruleorder: fastp > megahit

workdir: project_dir

rule all:
    input:
        expand("processed_reads/{sample}_report.html", sample=samples),
        expand("assemblies/{sample}/{sample}.done", sample=samples)
