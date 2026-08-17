nextflow.enable.types = true

process post_count {
    conda "anaconda::click"

    input:
    record(
        out_dir: Path,
        t2g_out: Path
    )

    output:
    record(out_dir: out_dir)

    script:
    """
    post_kbcount.py --input_dir ${out_dir} --t2g ${t2g_out} --output_dir ${out_dir}
    """
}