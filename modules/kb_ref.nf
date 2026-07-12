process kb_ref {
    conda "bioconda::kb-python"

    input:
    path fasta
    path gtf
    path decoy
    val tmp_dir
    val output_index
    val output_t2g
    val output_fasta


    output:
    path "${output_index}", emit: index
    path "${output_t2g}", emit: t2g
    path "${output_fasta}", emit: fasta
    
    script:
    """
    kb ref \
        ${fasta} \
        ${gtf} \
        -i ${output_index} \
        -g ${output_t2g} \
        -f1 ${output_fasta} \
        --d-list ${decoy} \
        --tmp ${tmp_dir} \
        2>&1 
    """
}