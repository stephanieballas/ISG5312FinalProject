import gzip
import os
import glob

ANNDIR = "/scratch/sballas/ISG5312FinalProject/results/07_annotation/snpeff"
OUTDIR = "/scratch/sballas/ISG5312FinalProject/results/08_analysis"
os.makedirs(OUTDIR, exist_ok=True)

outfile = os.path.join(OUTDIR, "all_variants_annotated.tsv")

with open(outfile, 'w') as out:
    out.write("Sample\tChrom\tPos\tRef\tAlt\tGene\tEffect\tImpact\tHGVS_p\n")
    for vcf in sorted(glob.glob(os.path.join(ANNDIR, "*.annotated.vcf.gz"))):
        sample = os.path.basename(vcf).replace(".annotated.vcf.gz", "")
        print(f"Processing {sample}...")
        with gzip.open(vcf, 'rt') as f:
            for line in f:
                if line.startswith("#"):
                    continue
                fields = line.strip().split('\t')
                chrom, pos, ref, alt = fields[0], fields[1], fields[3], fields[4]
                info = fields[7]
                ann = ""
                for entry in info.split(';'):
                    if entry.startswith('ANN='):
                        ann = entry[4:]
                        break
                if not ann:
                    continue
                first = ann.split(',')[0].split('|')
                gene   = first[3]  if len(first) > 3  else ""
                effect = first[1]  if len(first) > 1  else ""
                impact = first[2]  if len(first) > 2  else ""
                hgvs_p = first[10] if len(first) > 10 else ""
                out.write(f"{sample}\t{chrom}\t{pos}\t{ref}\t{alt}\t{gene}\t{effect}\t{impact}\t{hgvs_p}\n")

print("Done!")
