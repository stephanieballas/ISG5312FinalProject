#!/bin/bash
#SBATCH --job-name=fastqc_trimmed
#SBATCH --output=fastqc_trimmed_%x_%j.out
#SBATCH --error=fastqc_trimmed_%x_%j.err
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=06:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=stephanie.ballas@uconn.edu
#SBATCH --array=0-53%10

module load fastqc/0.12.1

INDIR=/scratch/sballas/ISG5312FinalProject/results/02_qc/trimmed_fastq
OUTDIR=/scratch/sballas/ISG5312FinalProject/results/02_qc/fastqc_trimmed
mkdir -p ${OUTDIR}

FILES=(${INDIR}/*_trimmed.fastq.gz)
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

echo "Processing: ${FILE}"
fastqc -t 4 -o ${OUTDIR} ${FILE}
