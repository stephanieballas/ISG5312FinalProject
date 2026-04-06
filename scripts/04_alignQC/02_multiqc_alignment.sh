#!/bin/bash
#SBATCH --job-name=multiqc_align
#SBATCH --output=scripts/04_alignQC/multiqc_align_%j.out
#SBATCH --error=scripts/04_alignQC/multiqc_align_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --partition=general
#SBATCH --qos=general

module load MultiQC/1.9

multiqc /scratch/sballas/ISG5312FinalProject/results/04_alignQC/samstats \
    --outdir /scratch/sballas/ISG5312FinalProject/results/04_alignQC \
    --filename multiqc_alignment_report

echo "Done"
