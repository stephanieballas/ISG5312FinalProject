# ISG5312 Final Project

Reproduction of selected computational figures from Minami et al. (2023), *Cell* 41(6):1048–1060. The paper identifies CDKN2A deletion as the major driver of lipid metabolic reprogramming in glioblastoma (GBM), and shows that CDKN2A-null tumors are selectively primed for ferroptosis via GPX4 inhibition.

## What this repo reproduces

Five figures from the paper using a subset of the public WES data (SRP442039) and the open-access lipidomics data (Mendeley doi:10.17632/kjtdgk3f25.1):

| Figure | Description |
|--------|-------------|
| 2C | Varimax PCA of gliomasphere lipidome by CDKN2A status + V1 boxplot |
| 2D | Volcano plot of differentially abundant lipid species |
| 2E | Altered lipid species binned by lipid cluster |
| 2F | Acyl tail length vs double bonds bubble plot |
| 3A | TAG species log2 fold-change with acyl composition breakdown |

## Data

**WES:** SRA study SRP442039 (BioProject PRJNA965893) — 9 paired tumor-normal GBM samples (18 runs), all NovaSeq 6000. Used to derive CDKN2A deletion status via CNV calling.

**Lipidomics:** Mendeley repository (doi:10.17632/kjtdgk3f25.1) — shotgun lipidomics for gliomasphere cultures (n=43) and bulk patient tumors (n=84). No access restrictions.

## Workflow

**Part 1 — WES pipeline (Xanadu HPC)**
1. Download FASTQs via SRA Toolkit (prefetch + fasterq-dump)
2. Adapter trimming with CutAdapt
3. Mouse read removal with BBsplit (hg38 vs mm10)
4. Alignment to hg38 with BWA-MEM v0.7.17
5. Duplicate marking + BQSR (GATK v4.2)
6. Somatic variant calling with MuTect2 (paired tumor-normal mode)
7. Copy number analysis with CNVkit — CDKN2A deletion calls on chr9p21

**Part 2 — Figure reproduction (R)**
1. Load and preprocess Mendeley lipidomics data
2. Merge with CDKN2A status calls from Part 1
3. Reproduce figures 2C, 2D, 2E, 2F, 3A

## Repository structure
```
ISG5312FinalProject/
├── data/                    Raw FASTQ files (not tracked by git)
├── genome/                  hg38 reference genome (not tracked by git)
├── resources/
│   ├── gnomad/              gnomAD germline VCF
│   ├── pon/                 Panel of Normals VCF
│   └── lipidomics/          Mendeley lipidomics data
├── results/
│   ├── 02_qc/               FastQC reports and trimmed FASTQs
│   ├── 03_alignment/        BWA index and aligned BAMs
│   ├── 04_alignQC/          Samtools stats
│   ├── 05_variantCalling/   MuTect2 VCF output
│   ├── 06_filteringAnnotating/  Filtered VCFs
│   ├── 07_annotation/       ANNOVAR output
│   ├── 08_cnv/              CNVkit output and CDKN2A status calls
│   └── 09_figures/          Reproduced figures (2C, 2D, 2E, 2F, 3A)
├── scripts/
│   ├── 01_downloadData/     
│   ├── 02_qc/               
│   ├── 03_alignment/        
│   ├── 04_alignQC/          
│   ├── 05_variantCalling/   
│   ├── 06_filteringAnnotating/
│   ├── 07_annotation/       
│   ├── 08_cnv/              
│   └── 09_figures/          R scripts for figure reproduction
└── README.md
```

## Software

**WES:** SRA Toolkit v3.0, CutAdapt v2.8, BBTools v38.58, BWA v0.7.17, GATK v4.2, CNVkit v0.99, Samtools v1.15

**Figures:** R 4.x, ggplot2, dplyr, factoextra

## Reference

Minami JK, Morrow D, Bayley NA, et al. CDKN2A deletion remodels lipid metabolism to prime glioblastoma for ferroptosis. *Cell.* 2023;41(6):1048–1060. https://doi.org/10.1016/j.cell.2023.04.044
=======
# ISG Final Project

## Project Overview
Re-analysis of publicly available whole-exome sequencing (WES) data from 18 
colorectal cancer (CRC) tumor samples deposited under NCBI BioProject PRJNA916617.
The goal is to identify somatic single nucleotide variants (SNVs) and 
insertions/deletions (indels) in known CRC driver genes using a tumor-only 
somatic variant calling workflow, and to compare results against mutation 
frequencies reported in the original publication.

## Original Study
Guo, L., Wang, Y., Yang, W., Wang, C., Guo, T., Yang, J., Shao, Z., Cai, G., Cai, S., Zhang, L., Hu, X., & Xu, Y. (2023). Molecular Profiling Provides Clinical Insights Into Targeted and Immunotherapies as Well as Colorectal Cancer Prognosis. Gastroenterology, 165(2), 414–428.e7. https://doi.org/10.1053/j.gastro.2023.04.029

## Dataset
- BioProject: PRJNA916617
- SRA Study: SRP415647
- 18 tumor WES samples (SRR22963697 - SRR22963714)
- Platform: Illumina NovaSeq 6000 (paired-end, WXS)
- Tumor sites: Right colon, Left colon, Rectum, Transverse colon
- Total data size: ~46 GB

## Workflow

### Step 1: Download Data
Raw FASTQ files downloaded from NCBI SRA 

### Step 2: Quality Control
- FastQC on raw reads
- Trimmomatic for adapter trimming and quality filtering
- FastQC on trimmed reads
- MultiQC

### Step 3: Alignment
- BWA-MEM alignment
- Samtools sort and index BAM files

### Step 4: Alignment QC
- Samtools stats
- MultiQC

### Step 5: Variant Calling
- Picard MarkDuplicates
- GATK BaseRecalibrator and ApplyBQSR
- GATK MuTect2 tumor-only mode with hg38 Panel of Normals
- GATK FilterMutectCalls with gnomAD germline filtering

### Step 6: Filtering and Annotating
- bcftools filtering and normalization
- Additional filtering on VAF and coverage

### Step 7: Annotation
- ANNOVAR functional annotation
- Databases: RefGene, COSMIC, ClinVar, dbSNP, gnomAD

## Repository Structure
- data/            Raw FASTQ files 
- genome/          hg38 reference genome 
- resources/       gnomAD and Panel of Normals VCFs
- results/         Output files from each analysis step
- scripts/         All numbered analysis scripts and SLURM logs
- README.md        This file

## Software
- SRA Toolkit v3.0
- FastQC v0.11.9
- Trimmomatic v0.39
- BWA v0.7.17
- Samtools v1.15
- Picard v2.27
- GATK v4.3
- ANNOVAR (latest)
- MultiQC v1.12
>>>>>>> d725fea5769b785c4243c438bfc43c9c640fe4e6
