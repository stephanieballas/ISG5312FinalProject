#!/bin/bash
#SBATCH --job-name=snpeff
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/07_annotation/snpeff_%A_%a.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/07_annotation/snpeff_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --array=1-26%8

module load snpEff/4.3q

PROJ=/scratch/sballas/ISG5312FinalProject
VCFDIR=${PROJ}/results/05_variantCalling/mutect2
OUTDIR=${PROJ}/results/07_annotation/snpeff
PAIRS=${PROJ}/scripts/05_variantCalling/tumor_normal_pairs.txt
SNPEFF_JAR=/isg/shared/apps/snpEff/4.3q/snpEff.jar

mkdir -p ${OUTDIR}

PAIR_LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${PAIRS})
TUMOR=$(echo  ${PAIR_LINE} | awk '{print $1}')
NORMAL=$(echo ${PAIR_LINE} | awk '{print $2}')
PAIR_NAME="${TUMOR}_vs_${NORMAL}"

VCF=${VCFDIR}/${PAIR_NAME}.PASS.vcf.gz
OUTVCF=${OUTDIR}/${PAIR_NAME}.annotated.vcf
STATS=${OUTDIR}/${PAIR_NAME}.snpeff_stats.html

echo "Annotating: ${PAIR_NAME}"

java -Xmx12g -jar ${SNPEFF_JAR} \
    -v \
    -stats ${STATS} \
    CanFam3.1.86 \
    ${VCF} \
    > ${OUTVCF}

echo "Done: ${PAIR_NAME}"
