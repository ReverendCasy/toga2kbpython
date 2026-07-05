include { twoBitToFa } from "./modules/twoBitToFa.nf"
include { samtools_faidx } from "./modules/samtools_faidx.nf"
include { create_gtf_for_kbpython } from "./modules/create_gtf.nf"
include { create_decoy } from "./modules/create_decoy.nf"
include { kb_ref } from "./modules/kb_ref.nf"


params {
    genome: Path
    reads: Path
    toga_dir: Path
    out_dir: Path
    tmp_dir: Path = "$TMPDIR" // will this work?
}

workflow{
    // read_channel = channel.fromPath(params.reads)
    genome_fa = "${params.tmp_dir}/genome.fa"
    bed_file = "${params.toga_dir}/query_annotation.bed"
    isoforms = "${params.toga_dir}/query_genes.tsv"
    gtf_file = "${params.tmp_dir}/query_annotation.gtf"
    kbref_tmp = "${params.tmp_dir}/kb_ref"
    kbref_out = "${params.out_dir}/kb_ref"
    kbref_index = "${kbref_out}/index.idx"
    kbref_t2g = "${kbref_out}/t2g.txt"
    kbref_fa = "${kbref_out}/cdna.fasta"
    decoy = "${params.tmp_dir}/decoy.fa"
    // part 1: kb_index_final.sh content

    // convert the 2bit genome to Fasta format
    twoBitToFa(params.genome, genome_fa)

    // create a Samtools index
    samtools_faidx(genome_fa)

    // create a GTF file for UTR-less annotation
    create_gtf_for_kbpython(bed_file, isoforms, gtf_file)

    // create a decoy file
    create_decoy(genome_fa, bed_file, decoy)

    // run kb ref
    kb_ref(
        genome_fa,
        gtf_file,
        decoy,
        kbref_tmp,
        kbref_index,
        kbref_t2g,
        kbref_fa
    )


    // modify the t2g.txt file

    // part 2: kb_python_final.sh steps
    
    // run kb-python count

    // cleanup
}