#!/bin/bash
#SBATCH --job-name=bwa_align2
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/03_alignment/bwa_align2_%A_%a.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/03_alignment/bwa_align2_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=24:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-19%6

module load bwa/0.7.17
module load samtools/1.20

PROJ=/scratch/sballas/ISG5312FinalProject
TRIMMED=${PROJ}/results/02_qc/trimmed_fastq
OUTDIR=${PROJ}/results/03_alignment/bwa_align
REF=${PROJ}/genome/CanFam3.1.fa

mkdir -p ${OUTDIR}

# Only the 19 missing samples
SAMPLES=(
    SRR11352515 SRR11352517 SRR11352518 SRR11352520 SRR11352521
    SRR11352522 SRR11352523 SRR11352524 SRR11352525 SRR11352528
    SRR11352529 SRR11352530 SRR11352531 SRR11352532
    SRR11392157 SRR11392160 SRR11392161 SRR11392162 SRR11392172
)

SAMPLE=${SAMPLES[$((SLURM_ARRAY_TASK_ID - 1))]}
R1=${TRIMMED}/${SAMPLE}_1_trimmed.fastq.gz
R2=${TRIMMED}/${SAMPLE}_2_trimmed.fastq.gz
OUTBAM=${OUTDIR}/${SAMPLE}.sorted.bam

echo "Aligning: ${SAMPLE}"

RG="@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ILLUMINA\tLB:${SAMPLE}_lib1\tPU:${SAMPLE}"

bwa mem \
    -t ${SLURM_CPUS_PER_TASK} \
    -R "${RG}" \
    ${REF} \
    ${R1} ${R2} \
  | samtools sort \
    -@ ${SLURM_CPUS_PER_TASK} \
    -o ${OUTBAM}

samtools index ${OUTBAM}

echo "Done: ${SAMPLE}"
