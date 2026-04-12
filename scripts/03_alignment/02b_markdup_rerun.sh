#!/bin/bash
#SBATCH --job-name=markdup2
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/03_alignment/markdup2_%A_%a.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/03_alignment/markdup2_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-2

module load GATK/4.3.0.0

PROJ=/scratch/sballas/ISG5312FinalProject
INDIR=${PROJ}/results/03_alignment/bwa_align
TMPDIR=/scratch/sballas/tmp
mkdir -p ${TMPDIR}

SAMPLES=(SRR11352526 SRR11392159)

SAMPLE=${SAMPLES[$((SLURM_ARRAY_TASK_ID - 1))]}

echo "Marking duplicates: ${SAMPLE}"

gatk MarkDuplicates \
    --INPUT  ${INDIR}/${SAMPLE}.sorted.bam \
    --OUTPUT  ${INDIR}/${SAMPLE}.markdup.bam \
    --METRICS_FILE ${INDIR}/${SAMPLE}.markdup.metrics.txt \
    --TMP_DIR ${TMPDIR} \
    --CREATE_INDEX true \
    --VALIDATION_STRINGENCY SILENT

echo "Done: ${SAMPLE}"
