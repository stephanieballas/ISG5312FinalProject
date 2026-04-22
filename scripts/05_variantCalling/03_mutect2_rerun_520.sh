#!/bin/bash
#SBATCH --job-name=mutect2_520
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/mutect2_520_%j.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/mutect2_520_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --time=72:00:00
#SBATCH --partition=general
#SBATCH --qos=general

module load GATK/4.3.0.0

PROJ=/scratch/sballas/ISG5312FinalProject
BAMDIR=${PROJ}/results/03_alignment/bwa_align
OUTDIR=${PROJ}/results/05_variantCalling/mutect2
REF=${PROJ}/genome/CanFam3.1.fa

TUMOR=SRR11352520
NORMAL=SRR11392181
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
