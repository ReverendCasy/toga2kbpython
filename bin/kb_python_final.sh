#!/bin/bash

db=$1
sample=$2
strand=$3
tissue=$4
trim_reads=$5
file2=$6
index=$7
output=$8

usage() {
    echo "This script runs kb_python on a sample using the indexed genome and trimmed reads"
    echo "Usage: kb_python.sh db sample strand tissue trim_reads file2 index [output]"
    echo "strandness of the sample: the default is unstranded; alternatively, reverse (more often) or forward"
    echo "trim_reads is the dir where you saved the trimmed reads; file2 is NA if only one pair of sequences"
    echo "index is path to the temp folder (e.g. temp_db)"
    echo "output is optional, default kb_python/db_sample_tissue"
    echo "e.g.: kb_python.sh HLcarPer2 ind1 reverse liver trim_reads NA temp_HLcarPer2_noUTR"
}

[ $# -eq 0 ] && { usage; exit 1; }
[ "$1" = "-h" ] || [ "$1" = "--help" ] && { usage; exit 0; }

echo check inputs
if [ -z "$output" ]; then
    output=kb_python/${db}_${sample}_${tissue}
fi
mkdir -p $output

## run kb-python
echo run kb_python

if [ "$file2" = "NA" ]; then
# only one pair of sequence
kb count -x BULK \
-o $output \
-i $index/kb/index.idx \
-g ${index}/kb/t2g.txt \
--strand=$strand \
--parity=paired \
--tcc --matrix-to-directories \
${trim_reads}/$sample/paired_1.fq.gz ${trim_reads}/$sample/paired_2.fq.gz

else
# two pairs of sequences: read files have to be in this order!
kb count -x BULK \
-o $output \
-i $index/kb/index.idx \
-g ${index}/kb/t2g.txt \
--strand=$strand \
--parity=paired \
--tcc --matrix-to-directories \
${trim_reads}/$sample/paired_F1_R1.fq.gz ${trim_reads}/$sample/paired_F1_R2.fq.gz \
${trim_reads}/$sample/paired_F2_R1.fq.gz ${trim_reads}/$sample/paired_F2_R2.fq.gz
fi


# post-kb cleanup
echo post-kb 
module unload R && module load R/4.4.1
post_kbpython.R $sample $db $tissue $output $index


# clean up
echo clean up
current=$PWD
cd ${output}
rm flens.txt  inspect.json  matrix.cells  matrix.ec  matrix.sample.barcodes  output.bus transcripts.txt
## keep run_info.json  and kb_info.json
rm -r counts_unfiltered  
mv quant_unfiltered/abundance_1/* ./
rm -r quant_unfiltered
cd $current
