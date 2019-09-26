#!/bin/bash
# 05_clip_overlap.sh

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10_log_files"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

# Global variables
GATK="/home/kylewellband/.bin/gatk/gatk" # Path to GATK4 wrapper
INPUT="06_deduplicated_bam"
OUTPUT="07_clipped_overlap"
METRICS="11_metrics"

# Load needed modules
module load bamUtil
module load samtools/1.8

for file in $(ls "$INPUT"/*.bam | perl -pe 's/\.bam//g')
do
    name=$(basename "$file")

    echo "Clipping overlap for sample: $name"

    # Clip overlap
    bam clipOverlap \
        --in $INPUT/"$name".bam \
        --out -.ubam \
        --unmapped --storeOrig OC --stats |
    samtools view -b -F 4 - \
        -o $OUTPUT/"$name".no_overlap.bam 2> $METRICS/"$name"_clipping_stats.txt

    # Index bam
    samtools index $OUTPUT/"$name".no_overlap.bam

done
