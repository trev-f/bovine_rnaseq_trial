process SamtoolsSortIndex {
    tag "${metadata.sampleName}"

    label 'samtools'

    label 'cpu_mid'
    label 'mem_mid'

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
