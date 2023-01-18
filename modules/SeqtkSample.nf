process SeqtkSample {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/seqtk:1.3--h7132678_4'

    publishDir "${params.baseDirData}/reads/trimmed/sampled", mode: 'copy', pattern: '*.fastq.gz'

    input:
        tuple val(metadata), file(reads)
        val sampleSize
    
    output:
        tuple val(metadata), file('*.fastq.gz'), emit: sampledReads

    script:
        // set variable values
        seed = 100

        """
        # sample R1
        seqtk sample \
            -s${seed} \
            ${reads[0]} \
            ${sampleSize} \
        | gzip -c \
        > ${metadata.sampleName}_trimmed_sampled-${sampleSize}_R1.fastq.gz

        # sample R2
        seqtk sample \
            -s${seed} \
            ${reads[1]} \
            ${sampleSize} \
        | gzip -c \
        > ${metadata.sampleName}_trimmed_sampled-${sampleSize}_R2.fastq.gz
        """
}
