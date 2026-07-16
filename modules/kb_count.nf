process kb_count {
    conda "bioconda::kb-python"

    input:
    path index // kb-ref index output
    path t2g // kb-ref gene-to-isoform mapping
    path forward_reads
    path reverse_reads
    // read_directory
    val strand // strandedness 
    val output // path to output directory
    val pairwise // boolean flag; if set, expects the input to be pairwise

    output:
    path "${output}", emit: out_dir
    path "abundance.gene.tsv", emit: abundance_gene
    path "abundance.tsv", emit: abundance
    path "kb_info.json", emit: kb_info
    path "run_info.json", emit: run_info


    script:
//     input_args = pairwise == true ? "${read_dir}/paired_1.fq.gz ${read_dir}/paired_2.fq.gz" : """ \
// ${read_dir}/paired_F1_R1.fq.gz \
// ${read_dir}/paired_F1_R2.fq.gz \
// ${read_dir}/paired_F2_R1.fq.gz \
// ${read_dir}/paired_F2_R2.fq.gz
// """

    """
    kb count -x BULK \
        -o ${output} \
        -i ${index} \
        -g ${t2g} \
        --strand=${strand} \
        --parity=paired \
        --tcc \
        --matrix-to-directories \
        ${forward_reads} ${reverse_reads} && \
    mv ${output}/quant_unfiltered/abundance_1/* ${output}/ && \
    for file in flens.txt inspect.json matrix.cells matrix.ec matrix.sample.barcodes output.bus transcripts.txt; do \
        rm -rf ${output}/\${file}; \
    done && \
    cp ${output}/abundance.tsv abundance.tsv && \
    cp ${output}/abundance.gene.tsv abundance.gene.tsv && \
    cp ${output}/kb_info.json . && \
    cp ${output}/run_info.json .
    """
}