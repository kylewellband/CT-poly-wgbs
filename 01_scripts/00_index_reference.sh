#!/bin/bash
# 00_index_reference.sh
# by: Kyle Wellband
# Sept. 8, 2019
#

# Copy script as it was run
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
GATK="/home/kylewellband/.bin/gatk/gatk" # Path to GATK4 wrapper
GENOME="02_reference/genome.fasta"  # Genomic reference.fasta
NCPUS=4
JAVA_OPTS="-Xmx16G"

# Modules
module load bwa 
module load samtools/1.8

# Build reference
echo "Building ${GENOME} index"

bwa index "$GENOME"

samtools fadix "$GENOME"

$GATK --java-options $JAVA_OPTS \
    CreateSequenceDictionary \
    -R $GENOME

