nextflow.enable.types = true

include { FastqPair } from "./types.nf"

process kb_count {
    conda "bioconda::kb-python"

    input:
    record(
        species: String,
        sample: String,
        key: String,
        read_dir: Path,
        reads: List<FastqPair>,
        index: Path,
        t2g: Path,
        fasta: Path,
        t2g_out: Path,
        // t2g: Path,
    )
    strand: String // strandedness 
    pairwise: Boolean // boolean flag; if set, expects the input to be pairwise

    output:
    record(
        out_dir: file(output),
        t2g_out: t2g_out,
    )  


    script:
    read_arg = reads
        .collectMany { p -> ["${read_dir}/${sample}/${p.forward}", "${read_dir}/${sample}/${p.reverse}"] }
        .join(' ')
    output = "${species}/${sample}"

    """
    kb count -x BULK \
        -o ${output} \
        -i ${index} \
        -g ${t2g} \
        --strand=${strand} \
        --parity=paired \
        --tcc \
        --matrix-to-directories \
        ${read_arg} && \
    mv ${output}/quant_unfiltered/abundance_1/* ${output}/ && \
    for file in counts_unfiltered flens.txt inspect.json matrix.cells matrix.ec matrix.sample.barcodes output.bus quant_unfiltered transcripts.txt; do \
        rm -rf ${output}/\${file}; \
    done && \
    cp ${t2g_out} ${output}/toga.kb.t2g.tsv
    """
}