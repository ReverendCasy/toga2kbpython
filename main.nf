/*
Copyright (c) 2026 The Hiller Lab at the Senckenberg Gessellschaft für Naturforschung
Distributed under the terms of the Apache License, Version 2.0.

Author: Yury V. Malovichko
Credits: Xueling Yi, Alejandro Gonzales-Iribarren
Version: v0.1
*/

include { twoBitToFa } from "./modules/twoBitToFa.nf"
include { samtools_faidx } from "./modules/samtools_faidx.nf"
include { create_gtf_for_kbpython } from "./modules/create_gtf.nf"
include { create_decoy } from "./modules/create_decoy.nf"
include { kb_ref } from "./modules/kb_ref.nf"
include { fix_t2g_names } from "./modules/fix_t2g_names.nf"
include { kb_count } from "./modules/kb_count.nf"
include { post_count } from "./modules/post_kbcount.nf"


params {
    genome: Path
    toga_dir: Path
    forward_reads: Path
    reverse_reads: Path
    out_dir: String
    include_utr = false
    strand: String = "unstranded"
    pairwise = false
}

workflow{

    main:
    // read_channel = channel.fromPath(params.reads)
    genome_fa = "genome.fa"
    bed_file = (
        params.include_utr ? "${params.toga_dir}/query_annotation.with_utr.bed" : "${params.toga_dir}/query_annotation.bed"
    )
    isoforms = "${params.toga_dir}/query_genes.tsv"
    gtf_file = "query_annotation.gtf"
    kbref_tmp = "kb-ref"
    kbcount_out = "kb-count"
    kbref_index = "index.idx"
    kbref_t2g = "t2g.txt"
    kbref_fa = "cdna.fasta"
    decoy = params.include_utr ? genome_fa : "decoy.fa"
    kbref_t2g_fixed = "toga.gene_names.txt"

    // part 1: kb_index_final.sh content
    genome_channel = channel.fromPath(params.genome)

    // convert the 2bit genome to Fasta format
    twoBitToFa(genome_channel, genome_fa)

    // create a Samtools index
    samtools_faidx(twoBitToFa.out)

    // create a GTF file for UTR-less annotation
    create_gtf_for_kbpython(bed_file, isoforms, gtf_file)

    // create a decoy file
    if (!params.include_utr) {
        create_decoy(twoBitToFa.out, bed_file, decoy)
    }

    // run kb ref
    kb_ref(
        twoBitToFa.out,
        create_gtf_for_kbpython.out,
        params.include_utr ? twoBitToFa.out : create_decoy.out,
        kbref_tmp,
        kbref_index,
        kbref_t2g,
        kbref_fa
    )

    // modify the t2g.txt file
    fix_t2g_names(kb_ref.out.t2g, kbref_t2g_fixed)

    // part 2: kb_python_final.sh steps
    // run kb-python count
    kb_count(
        kb_ref.out.index,
        // fix_t2g_names.out,
        kb_ref.out.t2g,
        // params.read_dir,
        params.forward_reads,
        params.reverse_reads,
        params.strand,
        kbcount_out,
        params.pairwise
    )

    // post-count table fix
    post_count(kb_count.out.out_dir, fix_t2g_names.out)

    publish:
    gene_names = fix_t2g_names.out
    abundance = kb_count.out.abundance
    kbcount_count = post_count.out.counts
    kbcount_tpm = post_count.out.tpm
}

output {
    gene_names {
        path { "${params.out_dir}" }
        mode "copy"
    }
    abundance {
        path { "${params.out_dir}" }
        mode "copy"
    }
    kbcount_count {
        path { "${params.out_dir}" }
        mode "copy"
    }
    kbcount_tpm {
        path { "${params.out_dir}" }
        mode "copy"
    }
}