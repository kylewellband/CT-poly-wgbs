#!/bin/bash
# 07_CTpoly_vcf_2_bed.sh
#

# Copy script as it was run
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
INPUT="08_raw_vcfs"
OUTPUT="09_filtered_bed"

# Modules
module load vcftools

# extract C/T polymorphisms from VCF and recode to BED
for file in $(ls "$INPUT"/*.vcf.gz | perl -pe 's/\.vcf\.gz//g')
do
    name=$(basename $file)
    
    echo "Processing VCF: $file"
    
    gunzip -c "$file".vcf.gz | 
    awk '($1 !~ /"#*"/) && ($4 == "C" && $5 == "T") || ($4 == "T" && $5 == "C") || ($4 == "G" && $5 == "A") || ($4 == "A" && $5 == "G"){
    	print $1 "\t" $2 - 1 "\t" $2 "\t" $1 "_" $2 "\t" $4 "\t" $5
    }' > $OUTPUT/"$name"_CT_AG_snps.bed
    
done
