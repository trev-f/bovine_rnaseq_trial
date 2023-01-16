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

    // store reads in a map
    def reads = [:]
    reads.reads1 = file(row.reads1)
    reads.reads2 = file(row.reads2)

    return [metadata, reads]
}
