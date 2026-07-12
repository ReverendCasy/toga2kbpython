process post_count {
    conda "anaconda::click"

    input:
    path input_dir
    path t2g_corr

    output:
    path "toga.kb.counts.tsv", emit: counts
    path "toga.kb.tpm.tsv", emit: tpm

    script:
    """
    post_kbcount.py --input_dir ${input_dir} --t2g ${t2g_corr} --output_dir .
    """
}