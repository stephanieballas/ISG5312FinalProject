#!/bin/bash
#SBATCH --job-name=fastqc_519
#SBATCH --output=scripts/02_qc/fastqc_519_%j.out
#SBATCH --error=scripts/02_qc/fastqc_519_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --partition=general
#SBATCH --qos=general

module load fastqc/0.12.1

TRIMMED=/scratch/sballas/ISG5312FinalProject/results/02_qc/trimmed_fastq
OUTDIR=/scratch/sballas/ISG5312FinalProject/results/02_qc/fastqc_trimmed

fastqc \
    ${TRIMMED}/SRR11352519_1_trimmed.fastq.gz \
    ${TRIMMED}/SRR11352519_2_trimmed.fastq.gz \
    --outdir ${OUTDIR} \
    --threads 2

echo "FastQC complete for SRR11352519"
