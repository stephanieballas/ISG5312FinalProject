#!/bin/bash
#SBATCH --job-name=multiqc_raw
#SBATCH --output=multiqc_raw_%x_%j.out
#SBATCH --error=multiqc_raw_%x_%j.err
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=stephanie.ballas@uconn.edu

FASTQC_DIR=/scratch/sballas/ISG5312FinalProject/results/02_qc/fastqc_raw
OUTDIR=/scratch/sballas/ISG5312FinalProject/results/02_qc/fastqc_raw

module load MultiQC/1.15

multiqc ${FASTQC_DIR} -o ${OUTDIR} --filename multiqc_raw_report
