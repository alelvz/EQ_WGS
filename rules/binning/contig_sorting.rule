rule deepmicroclass_predict:
    input:
        fasta = lambda wildcards: assembly_dict[wildcards.sample]
    output:
        predictions = "{sample}/DeepMicroClass/{sample}_final.contigs.fa_pred_one-hot_hybrid.tsv"
    conda: f"{env_dir}/deepmicroclass_env.yml"
    shadow: "shallow"
    resources: 
        mem_mb=100000
    threads: 6
    benchmark: "benchmarks/{sample}_deepmicroclass_predict.txt"
    log: "logs/{sample}_deepmicroclass_predict.log"
    shell:
        """
        DeepMicroClass predict -i {input.fasta} -o {wildcards.sample}/DeepMicroClass --device cpu --cpu_thread {threads}
        """

rule deepmicroclass_extract:
    input:
        fasta = lambda wildcards: assembly_dict[wildcards.sample],
        predictions = "{sample}/DeepMicroClass/{sample}_final.contigs.fa_pred_one-hot_hybrid.tsv"
    output:
        prokaryotes = "{sample}/DeepMicroClass/prokaryotes.fa",
        eukaryotes = "{sample}/DeepMicroClass/eukaryotes.fa",
        prokaryotic_viruses = "{sample}/DeepMicroClass/prokaryotic_viruses.fa",
        eukaryotic_viruses = "{sample}/DeepMicroClass/eukaryotic_viruses.fa",
        plasmids = "{sample}/DeepMicroClass/plasmids.fa"
    conda: f"{env_dir}/deepmicroclass_env.yml"
    shadow: "shallow"
    resources:
        mem_mb=10000
    benchmark: "{sample}/benchmarks/{sample}_deepmicroclass_extract.txt"
    log: "{sample}/logs/{sample}_deepmicroclass_extract.log"
    shell:
        """
	DeepMicroClass extract --tsv {input.predictions} --fasta {input.fasta} \
        --class Prokaryote --output {output.prokaryotes}

	DeepMicroClass extract --tsv {input.predictions} --fasta {input.fasta} \
        --class Eukaryote --output {output.eukaryotes}

	DeepMicroClass extract --tsv {input.predictions} --fasta {input.fasta} \
        --class EukaryoteVirus --output {output.eukaryotic_viruses}

	DeepMicroClass extract --tsv {input.predictions} --fasta {input.fasta} \
        --class ProkaryoteVirus --output {output.prokaryotic_viruses}

	DeepMicroClass extract --tsv {input.predictions} --fasta {input.fasta} \
        --class Plasmid --output {output.plasmids}
       """

rule get_all_prokaryotic_seqs:
    input:
        prokaryotes = "{sample}/DeepMicroClass/prokaryotes.fa",
        prokaryotic_viruses = "{sample}/DeepMicroClass/prokaryotic_viruses.fa",
        plasmids = "{sample}/DeepMicroClass/plasmids.fa"
    output: 
        "{sample}/DeepMicroClass/all_prokaryotic_seqs.fa"
    benchmark: "{sample}/benchmarks/get_all_prokaryotic_seqs.txt"
    log: "{sample}/logs/get_all_prokaryotic_seqs.log"
    shell:
        """
        ## For binning, group together all prokaryotic-related sequences, including viruses and plasmids

        #cat {input} > {output}
		cat {input.prokaryotes} {input.prokaryotic_viruses} {input.plasmids} 2>/dev/null > {output}
        """

