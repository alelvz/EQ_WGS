rule magscot_separate_bins:
    input:
        binning_results = "{sample}/magscot/MAGScoT.refined.contig_to_bin.out",
        contigs_fasta = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa"
    output:
        separate_bins = directory("{sample}/magscot_bins")
    conda: f"{env_dir}/pullseq_env.yml"
    resources:
        mem_mb = 16000,
        runtime = 2880
    benchmark: "{sample}/benchmarks/binning_separate_bins.txt"
    log: "{sample}/logs/binning_separate_bins.txt"
    shell:
         r"""
         # Create the output directory
         mkdir -p {output.separate_bins}
         
         # Read the binning results file
         cut -f 1 {input.binning_results} | \
         tail -n +2 | sort | uniq | rev | cut -f1 -d "/" | rev | \
         while read bin_name; do
             pullseq -i {input.contigs_fasta} -n <(grep -w "$bin_name" {input.binning_results} | cut -f 2) > \
         {output.separate_bins}/{wildcards.sample}_${{bin_name}}.fasta
         
         # Add bin name in front of the contig         
         sed -i "s/^>/> {wildcards.sample}_${{bin_name}}_/g" {output.separate_bins}/{wildcards.sample}_${{bin_name}}.fasta

         done
         """
