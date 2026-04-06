#!/bin/bash
#SBATCH --job-name=retrim_519
#SBATCH --output=scripts/02_qc/retrim_519_%j.out
#SBATCH --error=scripts/02_qc/retrim_519_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

module load Trimmomatic/0.39

INDIR=/scratch/sballas/ISG5312FinalProject/data
OUTDIR=/scratch/sballas/ISG5312FinalProject/results/02_qc/trimmed_fastq
ADAPTERS=/isg/shared/apps/Trimmomatic/0.39/adapters/TruSeq3-PE.fa

echo "Re-trimming SRR11352519..."

java -jar /isg/shared/apps/Trimmomatic/0.39/trimmomatic-0.39.jar PE -threads 8 \
    ${INDIR}/SRR11352519_1.fastq.gz \
    ${INDIR}/SRR11352519_2.fastq.gz \
    ${OUTDIR}/SRR11352519_1_trimmed.fastq.gz \
    ${OUTDIR}/SRR11352519_1_unpaired.fastq.gz \
    ${OUTDIR}/SRR11352519_2_trimmed.fastq.gz \
    ${OUTDIR}/SRR11352519_2_unpaired.fastq.gz \
    ILLUMINACLIP:${ADAPTERS}:2:30:10 \
    LEADING:3 TRAILING:3 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36

echo "Done: SRR11352519"
