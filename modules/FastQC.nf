process FastQC {
    tag "${metadata.sampleName}"

    container 'biocontainers/fastqc:v0.11.9_cv8'

    input:
        tuple val(metadata), file(reads)
    
    output:
        path '*.zip', emit: zip
    
    script:
        """
        fastqc ${reads[0]} ${reads[1]}
        """
}
