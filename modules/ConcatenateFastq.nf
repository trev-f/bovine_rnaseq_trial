process ConcatenateFastq {
    tag "${metadata.sampleName}"

    label 'base'

    input:
        tuple val(metadata), file(reads)
    
    output:
        tuple val(metadata), path('*.fastq.gz'), emit: catReads
    
    script:
        log.info "Reads to concatenate for ${metadata.sampleName}: ${reads}"

        """
        cat ${reads} > ${metadata.sampleName}.fastq.gz
        """
}
