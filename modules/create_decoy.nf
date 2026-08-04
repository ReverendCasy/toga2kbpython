process create_decoy {
    input:
    path genome
    path bed_file
    val decoy
    val include_utr

    output:
    path "${decoy}"

    script:
    """
    if [[ ${include_utr} = "false" ]]; then
        ## step 1: get the CDS exons in BED6 format
        bed12ToFraction -i ${bed_file} -o all_exons.bed6 -m cds -b ; \

        ## step 2: use the resulting exon BED file to mask the input genome
        bedtools maskfasta -fi ${genome} -bed all_exons.bed6 -fo ${decoy} -mc N ; \

        ## cleanup
        rm all_exons.bed6 ; \
    else cp ${genome} ${decoy} ; \ 
    fi
    """
}