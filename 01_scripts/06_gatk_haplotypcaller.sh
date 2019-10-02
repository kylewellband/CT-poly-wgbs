#!/bin/bash
# 06_gatk_haplotypcaller.sh
#

# Copy script as it was run
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
GATK="/home/kylewellband/.bin/gatk/gatk" # Path to GATK4 wrapper
JAVA_OPTS="-Xmx16G"
GENOME="02_reference/genome.fasta"  # Genomic reference.fasta
INPUT="07_clipped_overlap"
OUTPUT="08_raw_vcfs"
NCPUS=4
PLOIDY=80 # this should be N individuals x 2 for diploid organisms
MAX_COV=100 # maximum depth, downsamples sites to $MAX_COV where depth > $MAX_COV

# Modules
module load java/jdk/1.8.0_102

# call SNPs with GATK4 HaplotypeCaller
for file in $(ls "$INPUT"/*.bam | perl -pe 's/\.bam//g')
do
    name=$(basename $file)

    echo "Calling SNPs in: $file"

    cut -f1 ${GENOME}.fai | 
    parallel -j $NCPUS gatk --java-options $JAVA_OPTS \
            HaplotypeCaller \
            -R $GENOME \
            -I "$file".bam \
            -L {} \
            -O $OUTPUT/$"$name"_gatk_{}.vcf.gz \
            -stand-call-conf 30.0 \
            --dont-use-soft-clipped-bases \
            --sample-ploidy $PLOIDY \
            --max-reads-per-alignment-start $MAX_COV \
            --max-alternate-alleles 3 \
            --use-jdk-inflater \
            --use-jdk-deflater

done

