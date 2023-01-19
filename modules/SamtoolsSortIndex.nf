process SamtoolsSortIndex {
    tag "${metadata.sampleName}"

    label 'cpu_mid'
    label 'mem_mid'

    container 'quay.io/biocontainers/samtools:1.15--h1170115_1'

    publishDir "${params.baseDirData}/map", mode: 'copy', pattern: '*'

    input:
        tuple val(metadata), file(bam)
    
    output:
        tuple val(metadata), path('*.bam'), path('*.bai'), emit: bamIndexed

    script:
        """
        samtools sort \
            -@ ${task.cpus} \
            -o ${metadata.sampleName}_sorted.bam \
            ${bam}
        
        samtools index \
            -@ ${task.cpus} \
            -b ${metadata.sampleName}_sorted.bam
        """
}
