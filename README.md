# ISG5312 Final Project

Reproduction of Das et al. (2021), *Communications Biology* 4:1108. The paper identifies recurrent somatic mutations in canine osteosarcoma, finding TP53 and SETD2 as the top driver genes, and links TP53 mutation status to patient survival.

## What this repo reproduces

- Somatic variant calling in 26 paired tumor-normal canine osteosarcoma WES samples
- Mutation frequency plot of recurrently mutated genes
- Oncoprint of top mutated genes across all samples
- TP53 mutation status comparison across samples

## Data

**Tumor WES:** SRA BioProject PRJNA613479 — 26 canine osteosarcoma tumor samples
**Normal WES:** SRA BioProject PRJNA503860 — matched normal samples
**Reference genome:** CanFam3.1 (canine reference, fully public)

## Workflow

1. Download FASTQs via SRA Toolkit (prefetch + fasterq-dump)
2. Adapter trimming with CutAdapt
3. Alignment to CanFam3.1 with BWA-MEM v0.7.17
4. Duplicate marking + BQSR (GATK v4.2)
5. Somatic variant calling with MuTect2 (paired tumor-normal mode)
6. Filtering and annotation with bcftools + ANNOVAR
7. Mutation frequency and oncoplot figures in R (maftools)

## Repository structure
```
ISG5312FinalProject/
├── data/                        Raw FASTQ files (not tracked by git)
├── genome/                      CanFam3.1 reference genome (not tracked by git)
├── resources/
│   ├── gnomad/                  Germline resource VCF for MuTect2 filtering
│   └── pon/                     Panel of Normals VCF for MuTect2
├── results/
│   ├── 02_qc/                   FastQC reports and trimmed FASTQs
│   ├── 03_alignment/            BWA index and aligned BAMs
│   ├── 04_alignQC/              Samtools stats
│   ├── 05_variantCalling/       MuTect2 paired mode VCF output
│   ├── 06_filteringAnnotating/  Filtered VCFs
│   └── 07_annotation/           ANNOVAR output
├── scripts/
│   ├── 01_downloadData/         prefetch + fasterq-dump SLURM scripts
│   ├── 02_qc/                   CutAdapt + FastQC SLURM scripts
│   ├── 03_alignment/            BWA-MEM SLURM scripts
│   ├── 04_alignQC/              Samtools stats SLURM scripts
│   ├── 05_variantCalling/       MuTect2 SLURM scripts
│   ├── 06_filteringAnnotating/  FilterMutectCalls + bcftools SLURM scripts
│   └── 07_annotation/           ANNOVAR SLURM scripts
└── README.md
```

## Software

BWA v0.7.17, GATK v4.2, CutAdapt v2.8, Samtools v1.15, SRA Toolkit v3.0.5, ANNOVAR, R 4.x (maftools, ggplot2)

## Reference

Das S, Idate R, Parrish CR, et al. Immune pathways and TP53 missense mutations are associated with longer survival in canine osteosarcoma. *Communications Biology.* 2021;4:1108. https://doi.org/10.1038/s42003-021-02683-0
