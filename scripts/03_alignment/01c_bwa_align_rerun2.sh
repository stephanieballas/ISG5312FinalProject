#!/bin/bash
#SBATCH --job-name=bwa_align3
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/03_alignment/bwa_align3_%A_%a.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/03_alignment/bwa_align3_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=24:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-3

module load bwa/0.7.17
module load samtools/1.20

PROJ=/scratch/sballas/ISG5312FinalProject
TRIMMED=${PROJ}/results/02_qc/trimmed_fastq
OUTDIR=${PROJ}/results/03_alignment/bwa_align
REF=${PROJ}/genome/CanFam3.1.fa

SAMPLES=(SRR11352526 SRR11352527 SRR11392159)

SAMPLE=${SAMPLES[$((SLURM_ARRAY_TASK_ID - 1))]}
R1=${TRIMMED}/${SAMPLE}_1_trimmed.fastq.gz
R2=${TRIMMED}/${SAMPLE}_2_trimmed.fastq.gz
OUTBAM=${OUTDIR}/${SAMPLE}.sorted.bam

echo "Re-aligning: ${SAMPLE}"

# Remove corrupted file first
rm -f ${OUTBAM}

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
