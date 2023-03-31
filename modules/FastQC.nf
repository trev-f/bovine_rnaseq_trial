process FastQC {
    tag "${metadata.sampleName}"

    label 'fastqc'

    label 'mem_low'

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
