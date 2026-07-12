process fix_t2g_names {
    // conda "conda-forge::r==4.5"
    conda "anaconda::click,networkx"

    input:
    path t2g_in
    val t2g_out

    output:
    path "${t2g_out}"

    script:
    """
    kb_t2g.py --input ${t2g_in} --output ${t2g_out}
    """
    // """
    // kb_t2g.R SAMPLE_OUTPUT ${t2g_in} ${t2g_out}
    // """
}