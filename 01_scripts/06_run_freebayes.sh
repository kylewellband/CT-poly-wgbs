#!/bin/bash
# 06_run_freebayes.sh
#

# Copy script as it was run
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="10_log_files"
cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
VCFLIB="/home/kylewellband/.bin/freebayes/vcflib" # Path to vcflib
GENOME="02_reference/genome.fasta"  # Genomic reference.fasta
INPUT="07_clipped_overlap"
OUTPUT="08_raw_vcfs"
NCPUS=4
PLOIDY=80 # this should be N individuals x 2 for diploid organisms
POOL_MODEL="--pooled-discrete --use-best-n-alleles 4" # should I be using "-F 0.01 -C 2 --pooled-continuous" ?
MAX_COV=100 # maximum depth, exclude sites above this depth

# Modules
module load freebayes
module load vcflib

# Parallelize freebayes calling over 1 Mb regions
01_scripts/util/fasta_generate_regions.py "$GENOME".fai 1000000 | 
    parallel --progress --joblog $LOG_FOLDER/"$TIMESTAMP"_freebayes.log -k -j $NCPUS \
    freebayes \
        -f $GENOME \
        --region {} \
        -p $PLOIDY \
        $POOL_MODEL \
        --max-coverage $MAX_COV \
        $INPUT/*.bam | 
    $VCFLIB/scripts/vcffirstheader |
    $VCFLIB/bin/vcfstreamsort -w 1000 | 
    $VCFLIB/bin/vcfuniq > $OUTPUT/freebayes_unfiltered.vcf


