rule semibin:
    input:
        fasta = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa",
        bam = "{sample}/{sample}_metaG.reads.sorted.bam",
        bai = "{sample}/{sample}_metaG.reads.sorted.bam.bai",
        depth_file = "{sample}/contig_depth.txt"
    output:
        done = '{sample}/semibin.done',
        outdir = directory('{sample}/semibin')
    resources:
        mem_mb = 250000,
        runtime = 4320
    threads: 24
    params:
        tmpdir = config["tmp_dir"],
        min_contig_length = config["binning"]["min_contig_length"],
        environment_type = config["semibin"]["environment_type"]
    conda: f"{env_dir}/semibin2_env.yml"
    benchmark: "{sample}/benchmarks/semibin2.txt"
    log: "{sample}/logs/semibin2.txt"
    shell:
        """
        SemiBin2 \
        single_easy_bin \
        --tmpdir {params.tmpdir} \
        --engine auto \
        -m {params.min_contig_length} \
        --input-fasta {input.fasta} \
        --input-bam {input.bam} \
        --environment {params.environment_type} \
        --output {output.outdir}

        touch {output.done}
        """

rule semibin_contig_to_bin:
    input:
        bin_dir = "{sample}/semibin"
    output:
        contig_to_bin="{sample}/semibin/contig_to_bin.tsv",
    shadow: "shallow"
    shell:
        r"""
        gunzip -fk {input.bin_dir}/output_bins/*.fa.gz

        ls {input.bin_dir}/output_bins/*.fa | \
        xargs -I{{}} bash -c 'paste <(yes "{{}}" | \
        head -n $(grep -c "^>" {{}}) | \
        sed -e "s:{input.bin_dir}/output_bins/::g") \
        <(grep "^>" {{}} | \
        sed -e "s/>//g") <(yes "semibin" | \
        head -n $(grep -c "^>" {{}}))' | \
        sed -e 's/\.fa//g' > {output.contig_to_bin}
        """
