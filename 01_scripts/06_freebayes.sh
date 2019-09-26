#!/bin/bash
# 06_freebayes.sh
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
POOL_MODEL="-F 0.01 -C 2 --pooled-continuous" # alternative to give similar results to GATK: "--pooled-discrete --use-best-n-alleles 3"
MAX_COV=100 # maximum depth, exclude sites above this depth

# Modules
module load freebayes
module load vcflib

# Parallelize freebayes calling over 1 Mb regions
for file in $(ls "$INPUT"/*.bam | perl -pe 's/\.bam//g')
do
    name=$(basename $file)
    
    echo "Calling SNPs in: $file"
    
	01_scripts/util/fasta_generate_regions.py "$GENOME".fai 1000000 | 
    	parallel --progress --joblog $LOG_FOLDER/"$TIMESTAMP"_freebayes.log -k -j $NCPUS \
    	freebayes \
        	-f $GENOME \
        	--region {} \
        	-p $PLOIDY \
        	$POOL_MODEL \
        	--max-coverage $MAX_COV \
        	"$file".bam | 
    	$VCFLIB/scripts/vcffirstheader |
    	$VCFLIB/bin/vcfstreamsort -w 1000 | 
    	$VCFLIB/bin/vcfuniq | gzip > $OUTPUT/"$name"_freebayes.vcf.gz

done
