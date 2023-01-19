process StarRunMapping {
    tag "${metadata.sampleName}"
    
    container 'quay.io/biocontainers/star:2.7.10a--h9ee0642_0'

    label 'cpu_high'
    label 'mem_high'

    publishDir "${params.baseDirData}/map/star", mode: 'copy', pattern: '*.bam'
    publishDir "${params.baseDirData}/map/star/logs", mode: 'copy', pattern: '*Log*'

    input:
        path genomeIndex
        tuple val(metadata), file(reads)

    output:
        tuple val(metadata), path('*.bam'), emit: bam
        path '*Log.final.out', emit: logFinalOut
    
    script:
        """
        STAR \
            --genomeDir ${genomeIndex} \
            --readFilesIn ${reads[0]} ${reads[1]} \
            --readFilesCommand gunzip -c \
            --outFileNamePrefix ${metadata.sampleName} \
            --runThreadN ${task.cpus} \
            --outSAMtype BAM Unsorted \
            --outSAMunmapped Within
        """
}
