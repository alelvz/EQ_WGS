rule get_depth_of_coverage:
    input:
        bam = "{sample}/{sample}_metaG.reads.sorted.bam",
        bai = "{sample}/{sample}_metaG.reads.sorted.bam.bai"
    output:
        depth_file = "{sample}/contig_depth.txt",
    conda: f"{env_dir}/metabat2_env.yml"
    shadow: "shallow"
    resources:
        mem_mb = 24000,
        runtime = 1440
    benchmark: "{sample}/benchmarks/jgi_summarize_bam_contig_depths.txt"
    log: "{sample}/logs/jgi_summarize_bam_contig_depths.txt"
    shell:
        """
	jgi_summarize_bam_contig_depths --outputDepth {output.depth_file} \
        {input.bam}
        """

rule metabat2:
    input:
        fasta = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa",
        bam = "{sample}/{sample}_metaG.reads.sorted.bam",
        bai = "{sample}/{sample}_metaG.reads.sorted.bam.bai",
        depth_file = "{sample}/contig_depth.txt"
    output:
        bin_dir = directory('{sample}/metabat2'),
        done = '{sample}/metabat2.done'
    params:
        threads = config["metabat2"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"],
        prefix = '{sample}/metabat2/metabat_bin',
        reordered_depth_file = '{sample}/metabat2/contig_depth.txt'
    resources:
        mem_mb = 100000,
        runtime = 4320
    shadow: "shallow"
    conda: f"{env_dir}/metabat2_env.yml"
    benchmark: "{sample}/benchmarks/metabat2.txt"
    log: "{sample}/logs/metabat2.txt"
    shell:
        """
        mkdir -p {output.bin_dir}

        awk 'NR==FNR {{order[$1]=NR; next}} $1 in order {{print order[$1], $0}}' \
        <(grep '>' {input.fasta} | sed 's/>//') {input.depth_file} | \
        sort -k1,1n | cut -d' ' -f2- > {params.reordered_depth_file}

        metabat2 -t {params.threads} \
        -i {input.fasta} \
        -o {params.prefix} \
        -a {params.reordered_depth_file} \
        -m {params.min_contig_length}

	touch {output.done}
        """

rule metabat2_contig_to_bin:
    input:
        bin_dir = "{sample}/metabat2"
    output:
        contig_to_bin="{sample}/metabat2/contig_to_bin.tsv"
    shadow: "shallow"
    resources:
        mem_mb = 16000,
        runtime = 1440
    shell:
        r"""
        ls {input.bin_dir}/*.fa | \
        xargs -I{{}} bash -c 'paste <(yes "{{}}" | \
        head -n $(grep -c "^>" {{}}) | \
        sed -e "s:{input.bin_dir}/::g") \
        <(grep "^>" {{}} | \
        sed -e "s/>//g") <(yes "metabat2" | \
        head -n $(grep -c "^>" {{}}))' | \
        sed -e 's/\.fa//g' > {output.contig_to_bin}
        """

