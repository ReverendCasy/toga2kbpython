## v0.2
* Major input files are streamlined via the `--table` argument. The expected file contains paths to genome 2bit file, TOGA2 output directory, and two or more read files organized per species and sample. See `assets/sample_input/table.tsv` for example of the pipeline input.
* All code has migrated to static typing (v2 Nextflow parser format).


## v0.1
Initial version:
* Accepts a single genome, TOGA2 output directory, and paired RNAseq reads library as input
* Code is written with v1 parser in mind