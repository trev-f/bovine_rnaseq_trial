process RSeQCReadDistribution {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/rseqc:5.0.1--py38hbff2b2d_0'

    publishDir "${params.baseDirData}/rseqc", mode: 'copy', pattern: '*read_distribution.txt'

    input:
        tuple val(metadata), path(bam), path(bai)
        path bed12
    
    output:
        path '*read_distribution.txt', emit: readDistribution

    script:
        """
        read_distribution.py \
            -r ${bed12} \
            -i ${bam} \
        > ${metadata.sampleName}_read_distribution.txt
        """
}
