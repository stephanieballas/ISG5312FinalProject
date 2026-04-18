# ISG5312 Final Project
## Somatic Variant Calling in Canine Osteosarcoma
### Reproduction of Das et al. (2021), *Communications Biology* 4:1178

**Student:** Stephanie Ballas  
**Repository:** stephanieballas/ISG5312FinalProject  
**Cluster:** UConn Xanadu HPC

---

## Overview

> **[PENDING — complete after downstream analysis]**

---

## Introduction

> **[PENDING — complete after downstream analysis]**

---

## Project Overview

This project is a conceptual reproduction of Das et al. (2021), a whole exome sequencing (WES) study of canine osteosarcoma. The original paper identifies recurrent somatic mutations across 26 paired tumor-normal samples and finds that TP53 missense mutations and immune pathway enrichment are associated with longer patient survival.

This pipeline re-analyzes the same publicly available raw sequencing data, following GATK best practices for somatic short variant discovery, from raw FASTQ files through to functionally annotated variants.

> **Note:** This project was originally planned around a human glioblastoma dataset, but that dataset required dbGaP controlled access. After failing to identify a suitable publicly available human WES dataset, the project was redirected to this canine osteosarcoma WES dataset, which is fully public and well-documented.

### Reproduction Targets
- Somatic SNV and indel calling across 25 matched tumor-normal WES pairs
- Identification of recurrently mutated genes (especially TP53 and SETD2)
- Mutation frequency summary and oncoprint visualization
- TP53 mutation status comparison across samples

---

## Dataset

| Feature | Details |
|---|---|
| Species | *Canis lupus familiaris* (dog) |
| Tissue | Osteosarcoma tumor + matched peripheral blood normal |
| Sequencing | Paired-end WES, 151 bp, Illumina HiSeq 4000 |
| Tumor samples | 27 samples — BioProject PRJNA613479 (SRR11352506–SRR11352532) |
| Normal samples | 25 samples — BioProject PRJNA503860 (SRR11392157–SRR11392182, excluding SRR11392176) |
| Tumor-normal pairs analyzed | 25 (see Limitations) |
| Reference genome | CanFam3.1 (Ensembl release 104) |

---

## Repository Structure

```
ISG5312FinalProject/
├── README.md
├── .gitignore
├── scripts/
│   ├── 01_download/
│   │   └── 01_download_fastq.sh              # SRA Toolkit prefetch + fasterq-dump
│   ├── 02_qc/
│   │   ├── 01_fastqc_raw.sh                  # FastQC on raw FASTQs (array job)
│   │   ├── 02_multiqc_raw.sh                 # MultiQC pre-trim summary
│   │   ├── 03_trimmomatic.sh                 # Adapter + quality trimming (array job)
│   │   ├── 03b_retrim_SRR11352519.sh         # Re-trim for truncated sample
│   │   ├── 04_fastqc_trimmed.sh              # FastQC on trimmed FASTQs (array job)
│   │   └── 05_multiqc_trimmed.sh             # MultiQC post-trim summary
│   ├── 03_alignment/
│   │   ├── 01_bwa_index.sh                   # Index CanFam3.1 reference genome
│   │   └── 02_bwa_align.sh                   # BWA-MEM alignment + MarkDuplicates (array job, %6)
│   ├── 04_alignQC/
│   │   └── 01_alignQC.sh                     # samtools flagstat + MultiQC
│   ├── 05_variantCalling/
│   │   ├── tumor_normal_pairs.txt            # 25 tumor-normal pair mappings (SRR IDs)
│   │   ├── 01_mutect2.sh                     # GATK Mutect2 paired mode (array job, %4)
│   │   ├── 01_mutect2_rerun_timeouts.sh      # Rerun of 6 pairs that exceeded 24hr wall time
│   │   ├── 02_mutect2_rerun_f1r2.sh          # Rerun of 8 pairs missing f1r2 output
│   │   └── 02_filterMutect.sh                # LearnReadOrientationModel + FilterMutectCalls
│   └── 07_annotation/
│       └── 01_snpeff.sh                      # SnpEff annotation (CanFam3.1.86 database)
└── results/
    ├── 02_qc/
    │   ├── fastqc_raw/                       # Per-sample raw FastQC HTML reports
    │   ├── multiqc_raw/                      # Aggregated pre-trim MultiQC report
    │   ├── fastqc_trimmed/                   # Per-sample trimmed FastQC HTML reports
    │   └── multiqc_trimmed/                  # Aggregated post-trim MultiQC report
    ├── 04_alignQC/
    │   └── samstats/                         # Per-sample flagstat outputs + MultiQC report
    ├── 05_variantCalling/
    │   ├── mutect2/                          # Per-pair unfiltered VCFs + f1r2 tar.gz files
    │   └── filtered/                         # Filtered VCFs and PASS-only VCFs
    └── 07_annotation/
        └── snpeff/                           # Per-pair annotated VCFs + SnpEff HTML stats
```

> **Note:** Large files (FASTQs, BAMs, VCF.gz, genome files) are excluded from git via `.gitignore`. Only scripts, summary reports, and text-based results are tracked.

---

## Methods

> *The steps below constitute the full methods for this project. A brief prose summary will be added here once downstream analysis is complete.*

### Step 1 — Data Download

Raw FASTQ files were downloaded from NCBI SRA using SRA Toolkit for all 52 samples across both BioProjects.

```bash
prefetch ${SRR}
fasterq-dump --split-files ${SRR}
```

**Tools:** SRA Toolkit 3.0.5  
**Script:** `scripts/01_download/01_download_fastq.sh`

---

### Step 2 — Quality Control and Trimming

Pre-trimming FastQC was run on all 54 raw FASTQ pairs (27 tumor + 27 normal). Key observations:

- All samples: 151 bp paired-end reads
- Raw read counts: ~98M–181M reads per sample
- GC content: 50–55%, consistent with WES data
- Duplication rates: 37%–70% (elevated; expected for WES hybrid capture enrichment)
- Widespread flags for Sequence Duplication, Overrepresented Sequences, and Per Base Sequence Content
- Adapter content flags in ~4 samples pre-trimming

Trimmomatic was run in paired-end mode with the following parameters:

```
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10
LEADING:3
TRAILING:3
SLIDINGWINDOW:4:15
MINLEN:36
```

Post-trimming MultiQC confirmed successful adapter removal across all samples.

**Tools:** FastQC 0.11.x, Trimmomatic 0.39, MultiQC  
**Scripts:** `scripts/02_qc/`

> **Challenge:** SRR11352519 produced corrupted truncated trimmed FASTQ files on the initial run. The raw files were verified as intact (9.6G + 11G), and Trimmomatic was rerun on this sample alone via `03b_retrim_SRR11352519.sh` to regenerate valid output.

---

### Step 3 — Alignment

All 52 trimmed samples were aligned to the CanFam3.1 reference genome (Ensembl release 104) using BWA-MEM. Read group tags (`@RG`) were included as required for downstream GATK tools. Aligned reads were coordinate-sorted with samtools, then duplicate reads were flagged using GATK MarkDuplicates.

```bash
bwa mem -t 8 -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA\tLB:lib1" \
    CanFam3.1.fa ${R1} ${R2} | samtools sort -o ${SAMPLE}.sorted.bam

gatk MarkDuplicates -I ${SAMPLE}.sorted.bam -O ${SAMPLE}.markdup.bam \
    -M ${SAMPLE}.markdup.metrics.txt
```

**Tools:** BWA 0.7.17, samtools 1.12, GATK 4.3.0.0  
**Scripts:** `scripts/03_alignment/`

> **Challenges encountered:**
> - **Reference genome download failure:** `wget` was blocked by the Ensembl FTP server on Xanadu. Resolved by switching to `curl` with the correct Ensembl release-104 URL.
> - **Disk space errors:** 19 of 52 samples failed mid-alignment with "No space left on device" due to simultaneous temporary file writes at high concurrency. Resolved by reducing SLURM array concurrency from `%12` to `%6`.
> - **Corrupted BAMs:** 3 samples (SRR11352526, SRR11352527, SRR11392159) produced corrupted BAM files from the disk issue and required full re-alignment after the concurrency fix.

---

### Step 4 — Alignment QC

Post-alignment QC was run on all 52 final BAM files using samtools flagstat, aggregated with MultiQC.

**Tools:** samtools 1.12, MultiQC  
**Script:** `scripts/04_alignQC/01_alignQC.sh`

---

### Step 5 — Somatic Variant Calling

Somatic SNVs and indels were called for all 25 tumor-normal pairs using GATK Mutect2 in paired mode. The `--f1r2-tar-gz` flag collects read orientation data for downstream filtering. The flag `--disable-read-filter MateOnSameContigOrNoMappedMateReadFilter` was added to handle unmapped mate reads present in some samples.

```bash
gatk Mutect2 \
    -R CanFam3.1.fa \
    -I ${TUMOR}.markdup.bam -tumor ${TUMOR} \
    -I ${NORMAL}.markdup.bam -normal ${NORMAL} \
    --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
    -O ${PAIR}.unfiltered.vcf.gz \
    --f1r2-tar-gz ${PAIR}.f1r2.tar.gz
```

**Tools:** GATK 4.3.0.0  
**Scripts:** `scripts/05_variantCalling/01_mutect2.sh`

> **Challenges encountered:**
> - **Mutect2 timeouts:** 6 of 25 pairs exceeded the initial 24-hour SLURM wall time limit (pairs SRR11352508_vs_SRR11392160, SRR11352509_vs_SRR11392161, SRR11352515_vs_SRR11392166, SRR11352518_vs_SRR11392169, SRR11352519_vs_SRR11392171, SRR11352520_vs_SRR11392181). Most pairs completed in 18–21 hours. Resolved by resubmitting all 6 via `01_mutect2_rerun_timeouts.sh` with a 48-hour wall time limit.
> - **Missing f1r2 output:** 8 of 25 pairs (SRR11352518, SRR11352520, SRR11352522, SRR11352524, SRR11352528, SRR11352529, SRR11352531, SRR11352532 vs. their matched normals) were missing `f1r2.tar.gz` files. This was caused by two bugs: an initial job that concatenated tumor and normal IDs instead of separating them, and a subsequent rerun job submitted without the `--f1r2-tar-gz` flag. Resolved by rerunning all 8 pairs via `02_mutect2_rerun_f1r2.sh`.

---

### Step 6 — Variant Filtering

Unfiltered Mutect2 VCFs were processed in three steps:

1. **LearnReadOrientationModel** — learns strand-specific artifact signatures from f1r2 data
2. **FilterMutectCalls** — applies all Mutect2 filters plus the orientation bias model
3. **SelectVariants** — extracts PASS-only variants for annotation

```bash
gatk LearnReadOrientationModel -I ${PAIR}.f1r2.tar.gz -O ${PAIR}.orientation-model.tar.gz

gatk FilterMutectCalls -R CanFam3.1.fa \
    -V ${PAIR}.unfiltered.vcf.gz \
    --ob-priors ${PAIR}.orientation-model.tar.gz \
    -O ${PAIR}.filtered.vcf.gz

gatk SelectVariants -V ${PAIR}.filtered.vcf.gz --exclude-filtered -O ${PAIR}.PASS.vcf.gz
```

**Tools:** GATK 4.3.0.0  
**Script:** `scripts/05_variantCalling/02_filterMutect.sh`

---

### Step 7 — Functional Annotation

PASS variants from all 25 pairs were annotated using SnpEff with the CanFam3.1.86 database. Annotations include predicted variant effects (missense, nonsense, splice site, frameshift, etc.), affected gene names, and impact classifications (HIGH / MODERATE / LOW / MODIFIER).

```bash
java -Xmx12g -jar snpEff.jar -v \
    -stats ${PAIR}.snpeff_stats.html \
    CanFam3.1.86 \
    ${PAIR}.PASS.vcf.gz > ${PAIR}.annotated.vcf
```

**Tools:** SnpEff 4.3q (database: CanFam3.1.86)  
**Script:** `scripts/07_annotation/01_snpeff.sh`

---

### Step 8 — Downstream Analysis *(In Progress)*

Annotated VCFs will be converted to MAF format and analyzed in R using maftools to generate:

- Per-tumor variant burden summary
- Oncoprint of top mutated genes across all 25 samples
- Lollipop plot of TP53 mutations
- Comparison of mutation patterns between short- and long-survival groups

**Tools:** R 4.x, maftools, ggplot2

---


## Results

> **[PENDING — complete after downstream analysis]**
---

## Conclusions

> **[PENDING — complete after downstream analysis]**

---

## Limitations and Pipeline Challenges

### Analytical Limitations (deviations from Das et al.)

**BQSR skipped:** Base Quality Score Recalibration was omitted because Das et al. used an institutional known variants VCF (`Canis_familiaris_V89.vcf`) from Colorado State University that is not publicly available. The pipeline proceeds directly from MarkDuplicates to Mutect2. This may result in slightly less accurate base quality scores than the original study.

**T-343 excluded:** Tumor sample T-343 (SRR11352525) was excluded from variant calling because its matched normal N-343 (SRR11392176) was not available in the SRA repository at the time of download. This reduces the cohort from the 26 pairs described in Das et al. to **25 analyzable pairs**.

**Dataset change:** This project was originally planned around a human glioblastoma WES dataset. That dataset required dbGaP controlled access, which was not available. After failing to identify a suitable publicly accessible human dataset, the project was redirected to this canine osteosarcoma WES dataset.

### Technical Challenges Encountered During Pipeline Execution

**Reference genome download failure:** The initial attempt to download the CanFam3.1 reference genome using `wget` failed silently because Ensembl FTP connections were blocked on the Xanadu cluster. Resolved by switching to `curl` and identifying the correct Ensembl release-104 URL.

**SRR11352519 truncated trimming:** The initial Trimmomatic run for sample SRR11352519 produced corrupted truncated FASTQ files, causing FastQC to fail. The raw files were verified as intact and the sample was re-trimmed individually using a dedicated script (`03b_retrim_SRR11352519.sh`).

**19/52 alignment jobs failed with disk space error:** During the initial BWA-MEM alignment run, 19 of 52 samples failed mid-job with "No space left on device." This was caused by many jobs writing large temporary files to shared disk simultaneously at high concurrency. Resolved by resubmitting with reduced SLURM array concurrency (`%6` instead of `%12`).

**Three corrupted BAM files:** Samples SRR11352526, SRR11352527, and SRR11392159 produced corrupted BAM files as a result of the disk space failure above. These required full re-alignment after the concurrency issue was resolved. All three were successfully re-aligned and verified before downstream processing.

**Scale of the dataset:** Working with 52 samples meant that any scripting error — even minor ones — required identifying the problem, correcting the script, and resubmitting the full array before the pipeline could continue. This added significant debugging time at nearly every step.

**Mutect2 timeouts:** 6 of 25 tumor-normal pairs exceeded the initial 24-hour SLURM wall time limit and were cancelled (pairs SRR11352508_vs_SRR11392160, SRR11352509_vs_SRR11392161, SRR11352515_vs_SRR11392166, SRR11352518_vs_SRR11392169, SRR11352519_vs_SRR11392171, SRR11352520_vs_SRR11392181). Most pairs completed in 18–21 hours; these 6 exceeded the limit. Resolved by resubmitting all 6 via `01_mutect2_rerun_timeouts.sh` with a 48-hour time limit.

**Missing f1r2 output (8 pairs):** 8 of 25 pairs were missing `f1r2.tar.gz` files required for orientation bias filtering. This was caused by two separate scripting bugs: one job that incorrectly concatenated tumor and normal SRR IDs, and a subsequent rerun submitted without the `--f1r2-tar-gz` flag. Resolved by rerunning all 8 affected pairs via `02_mutect2_rerun_f1r2.sh`.

---

## Software

| Software Tool | Version | Purpose |
|---|---|---|
| SRA Toolkit | 3.0.5 | FASTQ download |
| FastQC | 0.11.x | Read quality assessment |
| Trimmomatic | 0.39 | Adapter and quality trimming |
| MultiQC | 1.x | QC report aggregation |
| BWA | 0.7.17 | Reference genome alignment |
| samtools | 1.12 | BAM sorting, indexing, flagstat |
| GATK | 4.3.0.0 | MarkDuplicates, Mutect2, FilterMutectCalls |
| SnpEff | 4.3q | Variant functional annotation |
| R / maftools | 4.x | Downstream mutation analysis |

All jobs were run on UConn Xanadu HPC using SLURM (general partition, general QOS).

---

## Reference

Das S, Idate R, Regan DP, Fowles JS, Lana SE, Thamm DH, Gustafson DL, Duval DL. (2021). Immune pathways and TP53 missense mutations are associated with longer survival in canine osteosarcoma. *Communications Biology*, 4:1178. https://doi.org/10.1038/s42003-021-02683-0
