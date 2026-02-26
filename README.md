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
