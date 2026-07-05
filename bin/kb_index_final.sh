#!/bin/bash

db=$1
toga=$2
utr=$3
output=$4

usage() {
    echo "this script prepares the reference genome fasta and reference annotation gtf (with or without utr), and then run kb_python index. All results are output in the output dir"
    echo "Usage: kb_index.sh db toga utr [output]"
    echo "NOTE: currently only tested using TOGA2 outputs; utr should be yes or no; output is optional, default temp_db"
    echo "e.g.: kb_index.sh HLcarPer2 /projects/hillerlab/genome/gbdb-HL/hg38/TOGA2 no temp_HLcarPer2"
}

[ $# -eq 0 ] && { usage; exit 1; }
[ "$1" = "-h" ] || [ "$1" = "--help" ] && { usage; exit 0; }

if [ -z "$output" ]; then
    output=temp_${db}
    echo output saved in $output
fi
mkdir -p $output


echo get the genome fasta
twoBitToFa /projects/hillerlab/genome/gbdb-HL/$db/$db.2bit $output/$db.fa
samtools faidx $output/$db.fa

## get the GTF annotation 
if [ "$utr" = "no" ]; then
    ## if UTR is not included, hard Mask CDS and pass this as decoy:
    echo UTR not included in annotation
    echo hard mask CDS
    bedToExons ${toga}/vs_${db}/query_annotation.bed stdout | bedCov -sort $db stdin -bed=stdout > $output/$db.CDS.bed
    # $db directs bedCov to /projects/hillerlab/genome//gbdb-HL/$db/chrom.sizes 
    bedtools maskfasta -fi $output/$db.fa -bed $output/${db}.CDS.bed -fo $output/$db.CDSmasked.fa -mc N
    rm $output/${db}.CDS.bed
    decoy=$output/$db.CDSmasked.fa

    ## generate gtf file from TOGA output query_annotation.bed (i.e., without UTR) using postoga
    ## NOTE the -tg options: bed, utr, both
    toga2_run_postoga.py -td ${toga}/vs_${db} -r hg38 -q $db -t gtf -tg bed -d /beegfs/$(pwd)/$output
    ## remove retro genes and cleanup the postoga output dir
    zcat $output/POSTOGA_*/query_annotation.gtf.gz | grep -i retro -v > $output/fragmented_annotation_noRETRO.gtf
    rm -r $output/POSTOGA_*
    gtf=$output/fragmented_annotation_noRETRO.gtf
fi

if [ "$utr" = "yes" ]; then
    # pass the genome as the decoy (kb_python default)
    echo use the annotation with UTR
    echo default decoy
    decoy=$output/$db.fa

    ## generate the gtf using the query_annotation.gtf.gz file in the TOGA dir (including UTR and retro genes; postoga output using query_annotation.with_utrs.bed)
    ## note that the gtf file may not be archived in the data freeze!
    zcat ${toga}/vs_${db}/query_annotation.gtf.gz \
    | grep -i retro -v > $output/fragmented_annotation_noRETRO_withUTR.gtf
    gtf=$output/fragmented_annotation_noRETRO_withUTR.gtf
fi

## index for kb-python
mkdir $output/kb

echo
echo kb ref -i $output/kb/index.idx -g $output/kb/t2g.txt -f1 $output/kb/cdna.fasta $output/$db.fa $gtf --d-list $decoy --tmp tmp_kb_$output
echo 

kb ref -i $output/kb/index.idx \
-g $output/kb/t2g.txt \
-f1 $output/kb/cdna.fasta \
$output/$db.fa $gtf \
--d-list $decoy \
--tmp tmp_kb_$output \
2>&1 

# get the transcript-gene index
echo get my transcript vs gene idex
module unload R && module load R/4.4.1
kb_t2g.R $db $output/kb/

# clean up
echo clean up
rm $output/$db.fa $output/$db.fa.fai
