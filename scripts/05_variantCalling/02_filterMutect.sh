#!/bin/bash
#SBATCH --job-name=filterMutect
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/filterMutect_%A_%a.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/05_variantCalling/filterMutect_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-26%8

module load GATK/4.3.0.0

PROJ=/scratch/sballas/ISG5312FinalProject
VCFDIR=${PROJ}/results/05_variantCalling/mutect2
OUTDIR=${PROJ}/results/05_variantCalling/filtered
REF=${PROJ}/genome/CanFam3.1.fa
PAIRS=${PROJ}/scripts/05_variantCalling/tumor_normal_pairs.txt

mkdir -p ${OUTDIR}

PAIR_LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${PAIRS})
TUMOR=$(echo  ${PAIR_LINE} | awk '{print $1}')
NORMAL=$(echo ${PAIR_LINE} | awk '{print $2}')
PAIR_NAME="${TUMOR}_vs_${NORMAL}"

echo "LearnReadOrientationModel: ${PAIR_NAME}"
gatk LearnReadOrientationModel \
    -I ${VCFDIR}/${PAIR_NAME}.f1r2.tar.gz \
    -O ${OUTDIR}/${PAIR_NAME}.read-orientation-model.tar.gz

echo "FilterMutectCalls: ${PAIR_NAME}"
gatk FilterMutectCalls \
    -R ${REF} \
    -V ${VCFDIR}/${PAIR_NAME}.unfiltered.vcf.gz \
    --ob-priors ${OUTDIR}/${PAIR_NAME}.read-orientation-model.tar.gz \
    -O ${OUTDIR}/${PAIR_NAME}.filtered.vcf.gz

echo "Extracting PASS variants: ${PAIR_NAME}"
gatk SelectVariants \
    -V ${OUTDIR}/${PAIR_NAME}.filtered.vcf.gz \
    --exclude-filtered \
    -O ${OUTDIR}/${PAIR_NAME}.PASS.vcf.gz

echo "Done: ${PAIR_NAME}"
