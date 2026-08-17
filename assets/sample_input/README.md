# Input structure

## `--table`
Starting from version `v0.2`, all major input files are provided to `toga2kbpython` via a single `--table` argument. The expected input is a tab-separated table. The file *must not* have a header but may contain variable number of columns depending on the number of RNAseq libraries provided. Mandatory columns are:
* `species`: species name. Output files will be stored per unique species name; if you have multiple genome assemblies or TOGA2 runs, consider giving them different species names (eg., `mm10` and `mm10_no_ChrX`).
* `genome`: path to the genome assembly file, in [2bit](https://genome.ucsc.edu/goldenpath/help/twoBit.html) format. If you have multiple different assemblies for the same query, consider giving them different file names.
* `toga_dir`: path to the TOGA2 output directory, with your RNAseq reference as TOGA query. If you have multiple TOGA2 results for your query (for example, annotations performed with different reference species), consider giving the directories unique names (e.g., `vs_my_query_REF1` and `vs_my_query_REF2`). This behavior might change in future releases.
* `reads`: RNAseq read directory. Each sample is expected to be represented with a subdirectory under `${read_dir}/`.
* `sample`: RNAseq sample, sequencing run, or batch name. Each sample is expected to be represented with a subdirectory under `${read_dir}/`.
* `F1`: forward sequencing reads file, in [FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) format. Can be compressed into `gzip` format. Expected to be found in the `${read_dir}/${sample}` directory.
* `R1`: reverse sequencing reads file, in [FASTQ](https://en.wikipedia.org/wiki/FASTQ_format) format. Can be compressed into `gzip` format. Expected to be found in the `${read_dir}/${sample}` directory.

You can specify multiple read libraries for the same sample. In this case, add forward and reverse columns after column 7 (`R1`). Note that for each library, forward read files should precede reverse reads: column 8 and even columns thereafter should contain forwards reads, while column 9 and further odd columns are reserved for reverse. All files are expected to be found in the `${read_dir}/${sample}` directory.

Consider the example in `table.tsv`:
* lines 1 and 2 describe `kb-count` runs for different RNAseq sample for species `my_query1`. These runs share the same genome file and TOGA2 output directory, hence genome indexing and `kb-ref` command will be run once for these two samples.
* line 3 describes input for the same species but with alternative TOGA2 input. To resolve the output structure properly, the query name and the output TOGA2 directory name have been modified accordingly. This run will use the same genome index as the first lines but all `kb-python` commands will be performed independently for this line.
* line 4 contains input for a yet another species. It also provides reads from two different RNAseq library as a part of the same sequencing sample, hence the two additional columns.

In total, for this input table `toga2kbpython` will run genome indexing twice (for `my_query1`/`my_query1_upd` and `my_query2`), create decoy and run `kb-ref` thrice (for `my_query1`, `my_query1_upd`, and `my_query2`), and `kb-count` four times for each RNAseq sample.
