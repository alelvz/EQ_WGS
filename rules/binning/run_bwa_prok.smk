rule bwa_index_assembly:
    input:
        fasta = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa",
    output:
        assembly_amb = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa.amb",
        assembly_bwt = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa.bwt",
        assembly_pac = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa.pac",
        assembly_ann = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa.ann",
        assembly_sa = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa.sa",
        done = "{sample}/DeepMicroClass/indexing.done"
    resources:
        mem_mb = 24000,
        runtime = 1440  # 24 hours × 60 minutes
    threads: 6
    conda: f"{env_dir}/bwa_env.yml"
    benchmark: "{sample}/benchmarks/bwa_indexing.txt"
    log: "{sample}/logs/bwa_indexing.log"
    shell:
        """
        bwa index {input.fasta}
        touch {output.done}
        """

rule bwa_mapping_on_assembly:
    input:
        r_1 = lambda wildcards: reads_dict[wildcards.sample]["R1"],
        r_2 = lambda wildcards: reads_dict[wildcards.sample]["R2"],
        r_se = lambda wildcards: reads_dict[wildcards.sample]["SE"],
        assembly = "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa",
        donefile = "{sample}/DeepMicroClass/indexing.done"
    output:
        '{sample}/{sample}_metaG.reads.sorted.bam'
    params:
        prefix = "{sample}/{sample}_metaG.reads",
        memory = 250
    resources:
        mem_mb = 250000,
        runtime = 1440  # 24 hours × 60 minutes
    threads: 24
    group: "bwa_mapping_on_assembly"
    conda: f"{env_dir}/bwa_env.yml"
    benchmark: "benchmarks/{sample}_bwa_mapping.txt"
    log: "logs/{sample}_bwa_mapping.log"
    shell:
        """
        SAMHEADER="@RG\\tID:{wildcards.sample}\\tSM:metaG"

        PREFIX={params.prefix}

        MEM_PER_CORE=$(({params.memory}/{threads}))

        # merge paired and se
        samtools merge --threads {threads} -f $PREFIX.merged.bam \
         <(bwa mem -v 1 -t {threads} -M -R \"$SAMHEADER\" {input.assembly} {input.r_1} {input.r_2} 2>> {log}| \
         samtools view --threads {threads} -bS -) \
         <(bwa mem -v 1 -t {threads} -M -R \"$SAMHEADER\" {input.assembly} {input.r_se} 2>> {log}| \
         samtools view --threads {threads} -bS -) 2>> {log}

        # sort
        samtools sort --threads {threads} -m ${{MEM_PER_CORE}}G $PREFIX.merged.bam > $PREFIX.sorted.bam 2>> {log}
        rm $PREFIX.merged.bam
        """
rule index_mg_bam:
    input:
        bam = '{sample}/{sample}_metaG.reads.sorted.bam'
    output:
        bai = '{sample}/{sample}_metaG.reads.sorted.bam.bai'
    group: "bwa_index_assembly"
    resources:
        mem_mb = 16000,
        runtime = 240  # 4 hours = 240 minutes
    conda: f"{env_dir}/bwa_env.yml"
    benchmark: "{sample}/benchmarks/index_bam.txt"
    log: "{sample}/logs/index_bam.txt"
    shell:
        """
        samtools index {input} > {log} 2>&1
        """
