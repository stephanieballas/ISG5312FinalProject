#!/bin/bash
#SBATCH --job-name=mutect2_f1r2
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/mutect2_f1r2_%A_%a.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/mutect2_f1r2_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --time=48:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-8%4

module load GATK/4.3.0.0

PROJ=/scratch/sballas/ISG5312FinalProject
BAMDIR=${PROJ}/results/03_alignment/bwa_align
OUTDIR=${PROJ}/results/05_variantCalling/mutect2
REF=${PROJ}/genome/CanFam3.1.fa

mkdir -p ${OUTDIR}

PAIRS=(
  "SRR11352518 SRR11392169"
  "SRR11352520 SRR11392181"
  "SRR11352522 SRR11392173"
  "SRR11352524 SRR11392175"
  "SRR11352528 SRR11392179"
  "SRR11352529 SRR11392180"
  "SRR11352531 SRR11392182"
  "SRR11352532 SRR11392163"
)

PAIR_LINE="${PAIRS[$SLURM_ARRAY_TASK_ID-1]}"
TUMOR=$(echo $PAIR_LINE | awk '{print $1}')
NORMAL=$(echo $PAIR_LINE | awk '{print $2}')
PAIR_NAME="${TUMOR}_vs_${NORMAL}"

echo "Running Mutect2 (f1r2 rerun): ${PAIR_NAME}"

gatk Mutect2 \
    -R ${REF} \
    -I ${BAMDIR}/${TUMOR}.markdup.bam -tumor ${TUMOR} \
    -I ${BAMDIR}/${NORMAL}.markdup.bam -normal ${NORMAL} \
    --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
    -O ${OUTDIR}/${PAIR_NAME}.unfiltered.vcf.gz \
    --f1r2-tar-gz ${OUTDIR}/${PAIR_NAME}.f1r2.tar.gz

echo "Done: ${PAIR_NAME}"
