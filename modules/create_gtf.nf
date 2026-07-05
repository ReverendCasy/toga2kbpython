process create_gtf_for_kbpython {

    conda "${moduleDir}/env.yaml"

    input:
    path bed_file
    path isoform_file
    path gtf_file

    output:
    path "${gtf_file}"

    script:
    """
    ## step 1: create a provisional isoform file
    isoforms_for_gtf.py ${isoform_file} ${bed_file} prov_isoforms.tsv

    ## step 2: create a GTF file
    bed2gtf -b ${bed_file} -i prov_isoforms.tsv -o ${gtf_file}

    ## step 3: clean the provisional file
    rm prov_isoforms.tsv
    """
}