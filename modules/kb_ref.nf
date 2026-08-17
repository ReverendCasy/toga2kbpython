nextflow.enable.types = true

process kb_ref {
    conda "bioconda::kb-python"

    input:
    record(
        fasta: Path,
        gtf: Path,
        decoy: Path,
        key: String,
    )

    output:
    record(
        index: file(index),
        t2g: file(t2g),
        fasta: file(cds),
        key: key
    )
    
    script:
    index = "${key}.index"
    t2g = "${key}.t2g"
    cds = "${key}.kbref.fasta"
    tmp_dir = "${key}_kbref_tmp"

    """
    kb ref \
        ${fasta} \
        ${gtf} \
        -i ${index} \
        -g ${t2g} \
        -f1 ${cds} \
        --d-list ${decoy} \
        --tmp ${tmp_dir} \
        2>&1 
    """
}