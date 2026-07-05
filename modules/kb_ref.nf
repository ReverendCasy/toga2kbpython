process kb_ref {
    input:
    path fasta
    path gtf
    path decoy
    val tmp_dir
    val output_index
    val output_t2g
    val output_fasta


    output:
    path "${output_index}"
    path "${output_t2g}"
    path "${output_fasta}"
    
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