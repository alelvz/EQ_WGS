rule vamb:
    input:
        fasta = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa",
        bam = "{sample}/{sample}_metaG.reads.sorted.bam",
        bai = "{sample}/{sample}_metaG.reads.sorted.bam.bai"
    output:
        outdir = directory('{sample}/vamb'),
        done = '{sample}/vamb.done'
    params:
        threads = config["vamb"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"]
    conda: f"{env_dir}/vamb_env.yml"
    resources:
        mem_mb = 100000,
        runtime = 4320
    benchmark: "{sample}/benchmarks/vamb.txt"
    log: "{sample}/logs/vamb.txt"
    shell:
        """
        rm -rf {output.outdir}

        vamb --outdir {output.outdir} \
        -p {params.threads} \
        --minfasta 10 \
        --fasta {input.fasta} \
        --bamfiles {input.bam} \
        -i 10 \
        -m {params.min_contig_length}

        touch {output.done}
        """

rule vamb_contig_to_bin:
    input:
        bin_dir = "{sample}/vamb"
    output:
        contig_to_bin="{sample}/vamb/contig_to_bin.tsv",
    shadow: "shallow"
    resources:
        mem_mb = 24000,
        runtime = 1440
    shell:
        r"""
        ls {input.bin_dir}/bins/*.fna | \
        xargs -I{{}} bash -c 'paste <(yes "{{}}" | \
        head -n $(grep -c "^>" {{}}) | \
        sed -e "s:{input.bin_dir}/bins/::g") \
        <(grep "^>" {{}} | \
        sed -e "s/>//g") <(yes "vamb" | \
        head -n $(grep -c "^>" {{}}))' | \
        sed -e 's/\.fna//g' > /tmp/tmp_file.tsv

	paste <(cut -f1 /tmp/tmp_file.tsv) \
        <(cut -f2 /tmp/tmp_file.tsv | cut -f1 -d ' ') \
        <(cut -f3 /tmp/tmp_file.tsv) > {output.contig_to_bin}
        """

