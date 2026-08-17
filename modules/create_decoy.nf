nextflow.enable.types = true

process create_decoy {
    input:
    record(
        fasta: Path,
        toga_dir: Path
    )
    include_utr: Boolean

    output:
    record(
        decoy: file(decoy),
        _genome: fasta.baseName,
        _toga_dir: "${toga_dir}".tokenize('/')[-1],
    )

    script:
    decoy = "${fasta}.decoy.fa"
    bed_file = include_utr ? "query_annotation.with_utrs.bed" : "query_annotation.bed"
    utr = include_utr ? "true" : "false"

    """
    if [[ ${utr} = "false" ]]; then
        ## step 1: get the CDS exons in BED6 format
        bed12ToFraction -i ${toga_dir}/${bed_file} -o all_exons.bed6 -m cds -b ; \

        ## step 2: use the resulting exon BED file to mask the input genome
        bedtools maskfasta -fi ${fasta} -bed all_exons.bed6 -fo ${decoy} -mc N ; \

        ## cleanup
        rm all_exons.bed6 ; \
    else cp ${fasta} ${decoy} ; \
    fi
    """
}
