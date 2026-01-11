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
    row["sample"]: {"R1": row["R1_process"], "R2": row["R2_process"], "SE": row["SE_process"]}
    for _, row in samples_table.iterrows()
}

# Create a dictionary mapping sample → assembly path
assembly_dict = {
    row["sample"]: row["Assembly"]
    for _, row in samples_table.iterrows()
}

# List of samples for rule expansion
samples = list(samples_table["sample"])

#output_dir = config['project_dir']
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
include: 'rules/binning/contig_sorting.rule'
include: 'rules/binning/run_bwa_prok.rule'
include: 'rules/binning/concoct.rule'
include: 'rules/binning/metabat2.rule'
include: 'rules/binning/maxbin2.rule'
include: 'rules/binning/semibin.rule'
include: 'rules/binning/marker_genes.rule'
include: 'rules/binning/contig_to_bin.rule'
include: 'rules/binning/bin_refinement.rule'
include: 'rules/binning/separate_bins.rule'
include: 'rules/binning/dereplication.rule'
#este no.. include: 'rules/binning/run_bat.rule'
#include: 'rules/binning/bakta_bins.rule'

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
        expand("{sample}/concoct/contig_to_bin.tsv", sample = samples),
        expand("{sample}/metabat2/contig_to_bin.tsv", sample = samples),
        expand("{sample}/maxbin2/contig_to_bin.tsv", sample = samples),
        expand("{sample}/semibin/contig_to_bin.tsv", sample = samples),
        expand("{sample}/magscot/markers.hmm", sample = samples),
        expand("{sample}/magscot/contig_to_bin.tsv", sample = samples),
        expand("{sample}/magscot/MAGScoT.refined.contig_to_bin.out", sample = samples),
        expand("{sample}/magscot_bins", sample = samples),
        "dereplication"
        #este no.. expand("taxonomy/{bin_id}.BAT.done", bin_id = bin_ids),
        #expand("bakta_derep_bins/{bin_id}/{bin_id}.txt", bin_id = bin_ids)

