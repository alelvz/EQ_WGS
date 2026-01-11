# EQ_WGS - Empty Quarter Whole Genome Sequencing Pipeline

A comprehensive Snakemake-based workflow for metagenomic analysis of soil samples from the Empty Quarter, including assembly, binning, and phage prediction.

**Author:** Alejandra Lopez-Velazquez
**Repository:** https://github.com/alelvz/EQ_WGS

## Overview

This pipeline processes whole genome sequencing data from soil metagenomes through three main stages:
1. **Assembly** - Quality control and de novo assembly of metagenomic reads
2. **Binning** - MAG (Metagenome-Assembled Genome) recovery and refinement
3. **Phage Prediction** - Identification of viral and plasmid sequences

## Directory Structure

```
EQ_WGS/
├── assembly.smk              # Assembly workflow
├── binning.smk               # Binning workflow
├── phage_prediction.smk      # Phage prediction workflow
├── launch_assembly.sh        # SLURM submission script for assembly
├── launch_binning.sh         # SLURM submission script for binning
├── launch_phages.sh          # SLURM submission script for phage prediction
├── config/
│   └── config.yml           # Main configuration file
├── envs/                    # Conda environment specifications
├── rules/                   # Snakemake rule modules
│   ├── assembly/
│   ├── binning/
│   └── phages/
└── src/                     # Source code and utilities
    └── PLASMe/              # Plasmid detection tool
```

## Requirements

- **Snakemake** (with conda support)
- **Conda/Mamba** for environment management
- **SLURM** cluster environment
- Access to required databases (see Configuration section)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/alelvz/EQ_WGS.git
cd EQ_WGS
```

2. Ensure Snakemake is installed in your conda environment:
```bash
conda activate snakemake
```

## Configuration

All workflow parameters are defined in [config/config.yml](config/config.yml). Key configuration sections:

### Input Data
- `samples_table`: TSV file with sample metadata and file paths
- `project_dir`: Main output directory
- Required columns in samples table:
  - `sample`: Sample identifier
  - `R1_raw`, `R2_raw`: Raw read paths
  - `R1_process`, `R2_process`, `SE_process`: Processed read paths
  - `Assembly`: Assembly file path
  - `Prokaryotes_fasta`: Prokaryotic sequences

### Database Paths
- `genomad`: geNomad database for virus/plasmid detection
- `virsorter2`: VirSorter2 database
- `vibrant`: VIBRANT database
- `plasme`: PlasMe database
- `phabox2`: Phabox2 database
- `bakta`: Bakta annotation database
- `catbat`: CAT/BAT taxonomy database
- `magscot`: MAGScoT marker gene database

### Tool Parameters
Each tool has configurable parameters including:
- `threads`: Number of CPU threads
- `runtime`: Maximum runtime in minutes
- `mem_mb`: Memory allocation in MB

## Workflows

### 1. Assembly Pipeline

Processes raw sequencing reads to produce quality-controlled assemblies.

**Steps:**
1. Quality control with `fastp`
2. De novo assembly with `MEGAHIT`
3. Contig renaming and standardization
4. Assembly quality assessment with `QUAST`

**Launch:**
```bash
sbatch launch_assembly.sh
```

**Outputs:**
- `processed_reads/{sample}_report.html` - QC reports
- `assemblies/{sample}/{sample}_contigs.fa` - Assembled contigs
- `assemblies/qc/{sample}/report.txt` - Assembly statistics

### 2. Binning Pipeline

Recovers MAGs from assembled contigs using multiple binning algorithms.

**Steps:**
1. Contig classification with `DeepMicroClass` (prokaryotes, eukaryotes, viruses, plasmids)
2. Read mapping to assemblies with `BWA`
3. Binning with four tools:
   - `CONCOCT`
   - `MetaBAT2`
   - `MaxBin2`
   - `SemiBin2`
4. Marker gene detection with `Prodigal` + `HMM` searches
5. Bin consolidation and refinement with `MAGScoT`
6. Dereplication with `dRep`
7. Optional: Annotation with `Bakta`
8. Optional: Taxonomy with `CAT/BAT`

**Launch:**
```bash
sbatch launch_binning.sh
```

**Key Outputs:**
- `{sample}/DeepMicroClass/` - Classified contigs by type
- `{sample}/[tool]/contig_to_bin.tsv` - Binning assignments
- `{sample}/magscot_bins/` - Refined bins
- `dereplication/dereplicated_genomes/` - Dereplicated MAG set

### 3. Phage Prediction Pipeline

Identifies viral sequences and plasmids using multiple prediction tools.

**Tools:**
- **geNomad**: Neural network-based virus/plasmid detection
- **VIBRANT**: Virus identification by iterating through BLAST
- **VirSorter2**: Machine learning virus detection
- **PHAMER**: Transformer-based phage identification
- **PlasMe**: Deep learning plasmid detection

**Launch:**
```bash
bash launch_phages.sh
```

**Outputs:**
- `prediction/{sample}/genomad/` - geNomad predictions
- `prediction/{sample}/vibrant/` - VIBRANT results
- `prediction/{sample}/virsorter2/` - VirSorter2 results
- `prediction/{sample}/phamer/` - PHAMER predictions
- `prediction/{sample}/plasme/` - PlasMe plasmid predictions

## Usage Examples

### Running a specific workflow

```bash
# Assembly only
sbatch launch_assembly.sh

# Binning only (requires assemblies)
sbatch launch_binning.sh

# Phage prediction only (requires prokaryotic contigs)
bash launch_phages.sh
```

### Testing individual rules

```bash
# Dry run to see what will be executed
snakemake -s assembly.smk --configfile config/config.yml -n

# Run specific sample
snakemake -s assembly.smk --configfile config/config.yml \
  assemblies/41PRr2/41PRr2_contigs.fa
```

### Unlocking workflow after interruption

```bash
snakemake -s binning.smk --configfile config/config.yml --unlock
```

## Computational Resources

The pipeline is optimized for SLURM HPC environments. Resource requirements vary by step:

- **Assembly (MEGAHIT)**: Up to 256 GB RAM, 16 cores, 120 hours
- **Binning (SemiBin)**: Up to 400 GB RAM, 24 cores, 72 hours
- **Phage prediction (VirSorter2/VIBRANT)**: Up to 128 GB RAM, 16 cores, 96 hours
- **Dereplication (dRep)**: Up to 250 GB RAM, 36 cores, 120 hours

See [config/config.yml](config/config.yml) for detailed resource allocations.

## Conda Environments

All tools are managed through conda environments defined in the `envs/` directory. Environments are automatically created by Snakemake on first use.

Key environments:
- `fastp.yml` - Read quality control
- `megahit.yml` - Assembly
- `deepmicroclass_env.yml` - Contig classification
- `semibin2_env.yml`, `metabat2_env.yml`, `maxbin2_env.yml`, `concoct_env.yml` - Binning
- `genomad_env.yml`, `virsorter2.yml`, `vibrant.yml` - Phage prediction
- `drep_env.yml` - MAG dereplication
- `bakta_env.yml` - Genome annotation

## Troubleshooting

### Common Issues

1. **Conda environment conflicts**:
   - Use `--conda-frontend mamba` for faster resolution
   - Ensure conda environments are stored in `conda_envs/`

2. **SLURM job failures**:
   - Check logs in `logs/` directory
   - Verify resource allocations match cluster limits
   - Use `--rerun-incomplete` to restart failed jobs

3. **Missing databases**:
   - Ensure all database paths in `config.yml` are accessible
   - Download required databases before running workflows

4. **Latency issues**:
   - Increase `--latency-wait` if working on shared filesystems
   - Currently set to 60 seconds

## Output Interpretation

### Assembly QC
- Check `assemblies/qc/{sample}/report.txt` for N50, L50, total length
- Good assemblies: N50 > 1kb, minimal contigs < 500bp

### Binning Quality
- Bins should have: Completeness > 75%, Contamination < 25%
- MAGScoT refines bins to improve quality
- dRep produces non-redundant genome set (ANI < 90%)

### Phage Predictions
- Consensus predictions across tools increase confidence
- Check `prediction/{sample}/*/` for tool-specific outputs
- geNomad and VirSorter2 are generally most reliable

## Citation

If you use this pipeline, please cite the individual tools:

- **MEGAHIT**: Li et al. (2015) Bioinformatics
- **geNomad**: Camargo et al. (2023) bioRxiv
- **VirSorter2**: Guo et al. (2021) Microbiome
- **VIBRANT**: Kieft et al. (2020) Microbiome
- **SemiBin**: Pan et al. (2022) Nature Communications
- **MetaBAT2**: Kang et al. (2019) PeerJ
- **MaxBin2**: Wu et al. (2016) Bioinformatics
- **CONCOCT**: Alneberg et al. (2014) Nature Methods
- **dRep**: Olm et al. (2017) ISME Journal
- **Bakta**: Schwengers et al. (2021) Microbial Genomics
- **DeepMicroClass**: Mineeva et al. (2023) bioRxiv
- **MAGScoT**: Mallawaarachchi et al. (2022) Bioinformatics
- **PlasMe**: Pellow et al. (2020) Microbiome
- **PHAMER**: Shang et al. (2023) Briefings in Bioinformatics

## Contributing

Issues and pull requests are welcome at https://github.com/alelvz/EQ_WGS

## License

This project uses multiple open-source bioinformatics tools. Please refer to individual tool licenses.

## Contact

For questions or issues, please open an issue on GitHub or contact the repository maintainer.
