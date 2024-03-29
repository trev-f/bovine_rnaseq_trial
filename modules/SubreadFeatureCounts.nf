process SubreadFeatureCounts {
    tag "${metadata.sampleName}"

    label 'subread'

    label 'cpu_mid'
    label 'mem_mid'

    publishDir "${params.baseDirData}/counts", mode: 'copy', pattern: '*.txt'

    input:
        tuple val(metadata), path(bam), path(bai)
        path gtf

    output:
        tuple val(metadata), path('*.txt'), emit: counts
        path '*.txt.summary',               emit: countsSummary
    
    script:
        def args = task.ext.args ?: ''

        """
        grep -v 'gene_id ""' ${gtf} > annotations.gtf

        featureCounts \
            -T ${task.cpus} \
            -a annotations.gtf -F GTF \
            -o ${metadata.sampleName}.txt \
            ${args} \
            ${bam}
        """
}
