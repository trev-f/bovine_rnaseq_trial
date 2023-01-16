process Fastp {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/fastp:0.23.2--h79da9fb_0'

    input:
        tuple val(metadata), file(reads)
    
    output:
        tuple val(metadata.sampleName), path('*.fastq.gz'), emit: readsTrimmed
    
    script:
        """
        fastp \
            --thread ${task.cpus} \
            -i ${reads[0]} \
            -I ${reads[1]} \
            -o {metadta.sampleName}_trimmed_R1.fastq.gz \
            -O {metadta.sampleName}_trimmed_R2.fastq.gz
        """
}
