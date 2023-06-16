process ConcatenateFastq {
    tag "${metadata.sampleName}"

    label 'base'

    publishDir "${params.baseDirData}/reads/cat", mode: 'copy', pattern: '*.fastq.gz'

    input:
        tuple val(metadata), file(reads1), file(reads2)
    
    output:
        tuple val(metadata), path('*.fastq.gz'), emit: catReads
    
    script:
        if (reads2) {
            """
            cat ${reads1} > ${metadata.sampleName}_R1.fastq.gz
            cat ${reads2} > ${metadata.sampleName}_R2.fastq.gz
            """
        }
        else {
            """
            cat ${reads1} > ${metadata.sampleName}_R1.fastq.gz
            """
        }
}
