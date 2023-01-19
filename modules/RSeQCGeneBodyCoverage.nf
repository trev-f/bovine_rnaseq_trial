process RSeQCGeneBodyCoverage {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/rseqc:5.0.1--py38hbff2b2d_0'

    publishDir "${params.baseDirData}/rseqc", mode: 'copy', pattern: '*.geneBodyCoverage.txt'

    input:
        tuple val(metadata), path(bam), path(bai)
        path bed12
    
    output:
        path '*.geneBodyCoverage.txt', emit: geneBodyCoverage

    script:
        """
        geneBody_coverage.py \
            -r ${bed12} \
            -i ${bam} \
            -o ${metadata.sampleName}
        """
}
