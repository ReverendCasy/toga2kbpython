/* A collection of Nextflow types and executables used throughout this pipeline
*/

record FastqPair{
    forward: Path
    reverse: Path
}

def process_input_line(line: List<String>) {
    /* Process an input table line, returning a record object containing data for further processing

    Table columns/record fields are:

    column 1: species
    column 2: 2bit
    column 3: TOGA2
    column 4: read_dir
    column 5: sample
    column 6: F1 reads
    column 7: R1 reads
    columns X/X+1: Fn/Rn reads
    */

    // the following three fields are expected to correspond across all entries in the table
    def species = line[0]
    def genome = line[1]
    def toga_dir = line[2]
    def read_dir = line[3]
    def sample = line[4]
    // for every two columns starting from line
    def read_pairs = line[5..-1].collate(2).collect { f, r -> record(forward: f, reverse: r) }

    record(
        species: species,
        genome: genome,
        toga_dir: toga_dir,
        read_dir: read_dir,
        sample: sample,
        reads: read_pairs
    )
}