nextflow.enable.types = true

process twoBitToFa {
    input:
    genome: Path

    output:
    record(
        fasta: file(output),
        _genome: genome_name
    )

    script:
    genome_name = "${genome}".tokenize('/')[-1]
    output = "${genome_name}.fa"
    """
    twoBitToFa ${genome} ${output}
    """
}