process twoBitToFa {
    input:
    path genome
    path output

    output:
    path "${output}"

    script:
    """
    twoBitToFa ${genome} ${output}
    """
}