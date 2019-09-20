#!/bin/bash
# 03_deduplicate_reads.sh
#

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10_log_files"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

# Global variables
GATK="/home/kylewellband/.bin/gatk/gatk" # Path to GATK4 wrapper
INPUT="05_aligned_bam"
OUTPUT="06_deduplicated_bam"
METRICS="11_metrics"


# Load needed modules
module load java/jdk/1.8.0_102

# Remove duplicates from bam alignments
for file in $(ls "$INPUT"/*.bam | perl -pe 's/\.bam//g')
do
    name=$(basename "$file")
    
    echo "Deduplicating sample: $name"

    $GATK --java-options $JAVA_OPTS \
        MarkDuplicatesWithMateCigar \
        -I "$file" \
        -O $OUTPUT/"$name".dedup.bam \
        -M "$METRICS"/"$name".metrics.txt \
        --REMOVE_DUPLICATES true \
        --use_jdk_inflater \
        --use_jdk_deflater
done
