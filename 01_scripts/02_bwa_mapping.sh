#!/bin/bash
# 02_bwa_mapping.sh
#

# Copy script as it was run
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
GENOME="02_reference/genome.fasta"  # Genomic reference.fasta
INPUT="04_trimmed_reads"
OUTPUT="05_aligned_bam"
NCPUS=4

# Modules
module load bwa
module load samtools/1.8

# Align reads
for file in $(ls "$INPUT"/*_R1.fastq.gz | perl -pe 's/_R[12]\.fastq\.gz//g')
do
    name=$(basename $file)
    
    echo "Aligning sample: $file"

    bwa mem -t $NCPUS \
        -R "@RG\tID:$name\tSM:$name\tPL:ILLUMINA" \
        "$GENOME" $INPUT/"$name"_R1.fastq.gz $INPUT/"$name"_R2.fastq.gz |
    samtools view -b -q5 |
    samtools sort -@ $NCPUS - -o "$OUTPUT"/"$name".bam
    
    samtools index "$OUTPUT"/"$name".bam

done &> | tee $LOG_FOLDER/"$TIMESTAMP"_mapping.log
