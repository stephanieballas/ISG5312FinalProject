#!/bin/bash
#SBATCH --job-name=mutect2_rerun
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/mutect2_rerun_%A_%a.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/mutect2_rerun_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --time=48:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-6%3

module load GATK/4.3.0.0

PROJ=/scratch/sballas/ISG5312FinalProject
BAMDIR=${PROJ}/results/03_alignment/bwa_align
OUTDIR=${PROJ}/results/05_variantCalling/mutect2
REF=${PROJ}/genome/CanFam3.1.fa

mkdir -p ${OUTDIR}

PAIRS=(
  "SRR11352508 SRR11392160"
  "SRR11352509 SRR11392161"
  "SRR11352515 SRR11392166"
  "SRR11352518 SRR11392169"
  "SRR11352519 SRR11392171"
  "SRR11352520 SRR11392181"
)

PAIR_LINE="${PAIRS[$SLURM_ARRAY_TASK_ID-1]}"
TUMOR=$(echo $PAIR_LINE | awk '{print $1}')
NORMAL=$(echo $PAIR_LINE | awk '{print $2}')
PAIR_NAME="${TUMOR}_vs_${NORMAL}"

echo "Running Mutect2: ${PAIR_NAME}"

gatk Mutect2 \
    -R ${REF} \
    -I ${BAMDIR}/${TUMOR}.markdup.bam -tumor ${TUMOR} \
    -I ${BAMDIR}/${NORMAL}.markdup.bam -normal ${NORMAL} \
    --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
    -O ${OUTDIR}/${PAIR_NAME}.unfiltered.vcf.gz \
    --f1r2-tar-gz ${OUTDIR}/${PAIR_NAME}.f1r2.tar.gz

echo "Done: ${PAIR_NAME}"
