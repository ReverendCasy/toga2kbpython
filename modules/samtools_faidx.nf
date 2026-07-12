process samtools_faidx {
    container "https://hub.docker.com/r/biocontainers/samtools"
    conda "bioconda::samtools==1.23.1"

    input:
    path genome

    output:
    path "${genome}.fai"

    script:
    """
    samtools faidx ${genome}
    """
}