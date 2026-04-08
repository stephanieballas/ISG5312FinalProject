#!/bin/bash
#SBATCH --job-name=bwa_index
#SBATCH --output=/scratch/sballas/ISG5312FinalProject/scripts/03_alignment/bwa_index_%j.out
#SBATCH --error=/scratch/sballas/ISG5312FinalProject/scripts/03_alignment/bwa_index_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --partition=general
#SBATCH --qos=general

module load bwa/0.7.17
module load samtools/1.20
module load GATK/4.3.0.0

GENOME_DIR=/scratch/sballas/ISG5312FinalProject/genome
REF=${GENOME_DIR}/CanFam3.1.fa

cd ${GENOME_DIR}

echo "Downloading CanFam3.1 reference genome using curl..."
curl -o Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz \
    "https://ftp.ensembl.org/pub/release-104/fasta/canis_lupus_familiaris/dna/Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz"

echo "Checking download..."
ls -lh Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz

echo "Decompressing..."
gunzip Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa.gz

echo "Renaming..."
mv Canis_lupus_familiaris.CanFam3.1.dna.toplevel.fa CanFam3.1.fa

echo "Checking genome file..."
ls -lh CanFam3.1.fa

echo "Creating samtools fai index..."
samtools faidx ${REF}

echo "Creating sequence dictionary for GATK..."
gatk CreateSequenceDictionary -R ${REF}

echo "Running BWA index (this takes 2-3 hours, this is normal)..."
bwa index ${REF}

echo "ALL DONE - genome is ready"
