rule maxbin2:
    input:
        fasta = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa",
        depth_file = "{sample}/contig_depth.txt"
    output:
        done = '{sample}/maxbin2.done',
        outdir = directory('{sample}/maxbin2'),
        outlog = '{sample}/maxbin2/maxbin2.log'
    params:
        threads = config["maxbin2"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"]
    conda: f"{env_dir}/maxbin2_env.yml"
    resources:
        mem_mb = 100000,
        runtime = 4320
    benchmark: "{sample}/benchmarks/maxbin2.txt"
    log: "{sample}/logs/maxbin2.txt"
    shell:
        """
        mkdir -p {output.outdir}

	run_MaxBin.pl -contig {input.fasta} \
        -thread {params.threads} \
        -abund {input.depth_file} \
        -min_contig_length {params.min_contig_length} \
        -out {output.outdir}/maxbin2

        touch {output.done}
        """

rule maxbin2_contig_to_bin:
    input:
        bin_dir = "{sample}/maxbin2"
    output:
        contig_to_bin="{sample}/maxbin2/contig_to_bin.tsv",
    resources:
        mem_mb = 24000,
        runtime = 1440
    shell:
       r"""
       ls {input.bin_dir}/*.fasta | \
       xargs -I{{}} bash -c 'paste <(yes "{{}}" | \
       head -n $(grep -c "^>" {{}}) | \
       sed -e "s:{input.bin_dir}/::g") \
       <(grep "^>" {{}} | \
       sed -e "s/>//g") <(yes "maxbin2" | \
       head -n $(grep -c "^>" {{}}))' | \
       sed -e 's/\.fasta//g' > {output.contig_to_bin}
       """

