#!/bin/bash
PROJ=/scratch/sballas/ISG5312FinalProject
ANNDIR=${PROJ}/results/07_annotation/snpeff
OUTDIR=${PROJ}/results/08_analysis
mkdir -p ${OUTDIR}

echo -e "Sample\tChrom\tPos\tRef\tAlt\tGene\tEffect\tImpact\tHGVS_p" > ${OUTDIR}/all_variants_annotated.tsv

for vcf in ${ANNDIR}/*.annotated.vcf.gz; do
    SAMPLE=$(basename $vcf .annotated.vcf.gz)
    zcat $vcf | grep -v "^#" | while read line; do
        CHROM=$(echo "$line" | cut -f1)
        POS=$(echo "$line" | cut -f2)
        REF=$(echo "$line" | cut -f4)
        ALT=$(echo "$line" | cut -f5)
        INFO=$(echo "$line" | cut -f8)
        ANN=$(echo "$INFO" | grep -o 'ANN=[^;]*' | sed 's/ANN=//')
        FIRST=$(echo "$ANN" | cut -d',' -f1)
        GENE=$(echo "$FIRST" | cut -d'|' -f4)
        EFFECT=$(echo "$FIRST" | cut -d'|' -f3)
        IMPACT=$(echo "$FIRST" | cut -d'|' -f3)
        HGVS_P=$(echo "$FIRST" | cut -d'|' -f11)
        echo -e "${SAMPLE}\t${CHROM}\t${POS}\t${REF}\t${ALT}\t${GENE}\t${EFFECT}\t${IMPACT}\t${HGVS_P}"
    done >> ${OUTDIR}/all_variants_annotated.tsv
done
echo "Done"
