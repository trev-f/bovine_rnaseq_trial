process RSeQCGeneBodyCoverage {
    tag "${metadata.sampleName}"

    label 'rseqc'

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
