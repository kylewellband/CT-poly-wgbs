# 04_merge_bams.sh
#

# Copy script as it was run
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
GENOME="02_reference/genome.fasta"  # Genomic reference.fasta
INPUT="06_dedup_bam"
OUTPUT="07_freebayes"
NCPUS=4

# Modules
module load samtools

samtools merge "$OUTPUT"/merged.bam "$INPUT"/*dedup.bam

samtools index "$OUTPUT"/merged.bam


