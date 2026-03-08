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
