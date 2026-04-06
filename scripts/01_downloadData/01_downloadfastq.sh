#!/bin/bash
#SBATCH --job-name=download_fastq
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=20G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=stephanie.ballas@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

module load sratoolkit/3.0.5

OUTDIR=/scratch/sballas/ISG5312FinalProject/data
mkdir -p ${OUTDIR}

# Tumor samples (PRJNA613479)
TUMOR_SAMPLES=(
    SRR11352506
    SRR11352507
    SRR11352508
    SRR11352509
    SRR11352510
    SRR11352511
    SRR11352512
    SRR11352513
    SRR11352514
    SRR11352515
    SRR11352516
    SRR11352517
    SRR11352518
    SRR11352519
    SRR11352520
    SRR11352521
    SRR11352522
    SRR11352523
    SRR11352524
    SRR11352525
    SRR11352526
    SRR11352527
    SRR11352528
    SRR11352529
    SRR11352530
    SRR11352531
    SRR11352532
)

# Normal samples (PRJNA503860) matched by sample ID
NORMAL_SAMPLES=(
    SRR11392158
    SRR11392159
    SRR11392160
    SRR11392161
    SRR11392162
    SRR11392163
    SRR11392170
    SRR11392164
    SRR11392165
    SRR11392166
    SRR11392167
    SRR11392168
    SRR11392169
    SRR11392171
    SRR11392181
    SRR11392172
    SRR11392173
    SRR11392174
    SRR11392175
    SRR11392176
    SRR11392177
    SRR11392178
    SRR11392179
    SRR11392180
    SRR11392157
    SRR11392182
    SRR11352532
)

ALL_SAMPLES=("${TUMOR_SAMPLES[@]}" "${NORMAL_SAMPLES[@]}")

for SRR in "${ALL_SAMPLES[@]}"; do
    echo "Downloading ${SRR}..."
    prefetch ${SRR} --output-directory ${OUTDIR}
    fasterq-dump ${OUTDIR}/${SRR}/${SRR}.sra \
        --outdir ${OUTDIR} \
        --split-files \
        --threads 4
    gzip ${OUTDIR}/${SRR}_1.fastq
    gzip ${OUTDIR}/${SRR}_2.fastq
    rm -rf ${OUTDIR}/${SRR}
    echo "Done: ${SRR}"
done

date
