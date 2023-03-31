workflow ParseDesignSWF {
    take:
        design
    
    main:
        Channel
            .fromPath( design, checkIfExists: true )
            .splitCsv( header: true )
            .map { createInputChannel(it) }
            .set { samples }
        
    emit:
        samples = samples
}


// create a list of data from the csv
def createInputChannel(LinkedHashMap row) {
    // store metadata in a map
    def metadata = [:]
    metadata.sampleName = row.sampleName

    // store reads in a list
    def reads = row.reads2 ? [file(row.reads1, checkIfExists: true), file(row.reads2, checkIfExists: true)] : [file(row.reads1, checkIfExists: true)]

    return [metadata, reads]
}
