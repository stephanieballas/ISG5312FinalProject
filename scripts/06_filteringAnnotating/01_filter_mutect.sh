#!/bin/bash
#SBATCH --job-name=filter_mutect
#SBATCH --output=scripts/06_filteringAnnotating/filter_%A_%a.out
#SBATCH --error=scripts/06_filteringAnnotating/filter_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=24G
#SBATCH --time=06:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-26%8

module load GATK/4.3.0.0

PROJ=/scratch/sballas/ISG5312FinalProject
VCFDIR=${PROJ}/results/05_variantCalling/mutect2
REF=${PROJ}/genome/CanFam3.1.fa
PAIRS=${PROJ}/scripts/05_variantCalling/tumor_normal_pairs.txt

PAIR_LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${PAIRS})
TUMOR=$(echo  ${PAIR_LINE} | awk '{print $1}')
NORMAL=$(echo ${PAIR_LINE} | awk '{print $2}')
PAIR_NAME="${TUMOR}_vs_${NORMAL}"

echo "Filtering: ${PAIR_NAME}"

gatk LearnReadOrientationModel \
    -I ${VCFDIR}/${PAIR_NAME}.f1r2.tar.gz \
    -O ${VCFDIR}/${PAIR_NAME}.read-orientation-model.tar.gz

gatk FilterMutectCalls \
    -R ${REF} \
    -V ${VCFDIR}/${PAIR_NAME}.unfiltered.vcf.gz \
    --ob-priors ${VCFDIR}/${PAIR_NAME}.read-orientation-model.tar.gz \
    -O ${VCFDIR}/${PAIR_NAME}.filtered.vcf.gz

gatk SelectVariants \
    -R ${REF} \
    -V ${VCFDIR}/${PAIR_NAME}.filtered.vcf.gz \
    --exclude-filtered \
    -O ${VCFDIR}/${PAIR_NAME}.PASS.vcf.gz

PASS_COUNT=$(zcat ${VCFDIR}/${PAIR_NAME}.PASS.vcf.gz | grep -v "^#" | wc -l)
echo "PASS variants for ${PAIR_NAME}: ${PASS_COUNT}"
