process ConcatenateFastq {
    tag "${metadata.sampleName}"

    label 'base'

    input:
        tuple val(metadata), file(reads)
    
    output:
        tuple val(metadata), path('*.fastq.gz'), emit: catReads
    
    script:
        """
        cat ${reads} > ${metadata.sampleName}.fastq.gz
        """
}
