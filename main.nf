nextflow.enable.dsl=2

Channel
    .fromPath( params.input, checkIfExists: true )
    .splitCsv( header: true )
    .map { createInputChannel(it) }
    .view { it }

// create a list of data from the csv
def createInputChannel(LinkedHashMap row) {
    // store metadata in a map
    def metadata = [:]
    metadata.sampleName = row.sampleName

    // store reads in a map
    def reads = [:]
    reads.reads1 = file(row.reads1)
    reads.reads2 = file(row.reads2)

    return [metadata, reads]
}
