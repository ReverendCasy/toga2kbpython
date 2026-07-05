process samtools_faidx {
    container "https://hub.docker.com/r/biocontainers/samtools"
    input:
    path genome

    output:
    path "${genome}.idx"

    script:
    """
    samtools faidx ${genome}
    """
}