process twoBitToFa {
    input:
    path genome
    val output

    output:
    path "${output}"

    script:
    """
    twoBitToFa ${genome} ${output}
    """
}