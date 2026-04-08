#!/bin/bash
#SBATCH --job-name=mutect2
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/mutect2_%A_%a.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/mutect2_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --time=24:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-26%4

module load GATK/4.3.0.0

PROJ=/scratch/sballas/ISG5312FinalProject
BAMDIR=${PROJ}/results/03_alignment/bwa_align
OUTDIR=${PROJ}/results/05_variantCalling/mutect2
REF=${PROJ}/genome/CanFam3.1.fa
PAIRS=${PROJ}/scripts/05_variantCalling/tumor_normal_pairs.txt

mkdir -p ${OUTDIR}

PAIR_LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${PAIRS})
TUMOR=$(echo  ${PAIR_LINE} | awk '{print $1}')
NORMAL=$(echo ${PAIR_LINE} | awk '{print $2}')
PAIR_NAME="${TUMOR}_vs_${NORMAL}"

echo "Running Mutect2: ${PAIR_NAME}"

gatk Mutect2 \
    -R ${REF} \
    -I ${BAMDIR}/${TUMOR}.markdup.bam  -tumor  ${TUMOR} \
    -I ${BAMDIR}/${NORMAL}.markdup.bam -normal ${NORMAL} \
    --disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
    -O ${OUTDIR}/${PAIR_NAME}.unfiltered.vcf.gz \
    --f1r2-tar-gz ${OUTDIR}/${PAIR_NAME}.f1r2.tar.gz

echo "Done: ${PAIR_NAME}"
