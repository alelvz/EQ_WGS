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

# Create a dictionary mapping sample → assembly path
assembly_dict = {
    row["sample"]: row["Assembly"]
    for _, row in assembly_table.iterrows()
}

# Also map sample → R1/R2 if needed later
reads_dict = {
    row["sample"]: {"R1": row["R1_process"], "R2": row["R2_process"], "SE": row["SE_process"]}
    for _, row in assembly_table.iterrows()
}

# List of samples for rule expansion
samples = list(assembly_table["sample"])

output_dir = config['project_dir']
binning_dir = config['binning_dir']

mags_dir = binning_dir + "/dereplication/dereplicated_genomes"

# Get all .fasta files in the directory
genomes = glob(os.path.join(mags_dir, "fixed_fasta/*.fasta"))

# Create a mapping from bin IDs to genome paths
bins_index = {
    os.path.splitext(os.path.basename(genome))[0]: genome
    for genome in genomes
}

# Optional: list of bin IDs (keys)
bin_ids = list(bins_index.keys())

# Rules
include: 'rules/binning/contig_sorting.smk'
include: 'rules/binning/run_bwa_prok.smk'
include: 'rules/binning/concoct.smk'
include: 'rules/binning/metabat2.smk'
include: 'rules/binning/maxbin2.smk'
include: 'rules/binning/semibin.smk'
include: 'rules/binning/marker_genes.smk'
include: 'rules/binning/contig_to_bin.smk'
include: 'rules/binning/bin_refinement.smk'
include: 'rules/binning/separate_bins.smk'
include: 'rules/binning/dereplication.smk'
#include: 'rules/binning/run_bat.rule'
include: 'rules/binning/bakta_bins.rule'

ruleorder: deepmicroclass_predict > bwa_mapping_on_assembly

workdir:
    binning_dir

rule all:
    input:
        expand("{sample}/DeepMicroClass/prokaryotes.fa", sample = samples),
        expand("{sample}/DeepMicroClass/eukaryotes.fa", sample = samples),
        expand("{sample}/DeepMicroClass/prokaryotic_viruses.fa", sample = samples),
        expand("{sample}/DeepMicroClass/eukaryotic_viruses.fa", sample = samples),
        expand("{sample}/DeepMicroClass/plasmids.fa", sample = samples),
        expand("{sample}/DeepMicroClass/all_prokaryotic_seqs.fa", sample = samples),
        expand("{sample}/{sample}_metaG.reads.sorted.bam", sample = samples),
        expand("{sample}/{sample}_metaG.reads.sorted.bam.bai", sample = samples),
        expand("{sample}/concoct/bins", sample = samples),
        expand("{sample}/metabat2.done", sample = samples),
        expand("{sample}/metabat2/contig_to_bin.tsv", sample = samples),
        expand("{sample}/maxbin2.done", sample = samples),
        expand("{sample}/maxbin2/contig_to_bin.tsv", sample = samples),
        expand("{sample}/semibin.done", sample = samples),
        expand("{sample}/magscot/MAGScoT.refined.contig_to_bin.out", sample = samples),
        expand("{sample}/magscot", sample = samples),
        expand("{sample}/magscot_bins", sample = samples),
        "dereplication",
#        expand("taxonomy/{bin_id}.BAT.done", bin_id = bin_ids),
        expand("bakta_derep_bins/{bin_id}/{bin_id}.txt", bin_id = bin_ids)
#
