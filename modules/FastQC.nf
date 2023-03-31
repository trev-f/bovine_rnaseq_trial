process FastQC {
    tag "${metadata.sampleName}"

    label 'mem_low'

    container 'biocontainers/fastqc:v0.11.9_cv8'

    input:
        tuple val(metadata), file(reads)
    
    output:
        path '*.zip', emit: zip
    
    script:
        // set reads argument based on whether sample is single- or paired-end reads
        readsArg = reads[1] ? "${reads[0]} ${reads[1]}" : "${reads[0]}"

        """
        fastqc ${readsArg}
        """
}
