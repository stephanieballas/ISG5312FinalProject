#!/bin/bash
#SBATCH --job-name=trimmomatic
#SBATCH --output=trimmomatic_%x_%j.out
#SBATCH --error=trimmomatic_%x_%j.err
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=stephanie.ballas@uconn.edu
#SBATCH --array=0-53%8

module load Trimmomatic/0.39

INDIR=/scratch/sballas/ISG5312FinalProject/data
OUTDIR=/scratch/sballas/ISG5312FinalProject/results/02_qc/trimmed_fastq
ADAPTERS=/isg/shared/apps/Trimmomatic/0.39/adapters/TruSeq3-PE.fa

mkdir -p ${OUTDIR}

SAMPLES=($(ls ${INDIR}/*_1.fastq.gz | xargs -n1 basename | sed 's/_1.fastq.gz//'))
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

R1=${INDIR}/${SAMPLE}_1.fastq.gz
R2=${INDIR}/${SAMPLE}_2.fastq.gz

echo "Processing: ${SAMPLE}"

java -jar /isg/shared/apps/Trimmomatic/0.39/trimmomatic-0.39.jar PE -threads 8 \
    ${R1} ${R2} \
    ${OUTDIR}/${SAMPLE}_1_trimmed.fastq.gz ${OUTDIR}/${SAMPLE}_1_unpaired.fastq.gz \
    ${OUTDIR}/${SAMPLE}_2_trimmed.fastq.gz ${OUTDIR}/${SAMPLE}_2_unpaired.fastq.gz \
    ILLUMINACLIP:${ADAPTERS}:2:30:10 \
    LEADING:3 TRAILING:3 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36

echo "Done: ${SAMPLE}"
