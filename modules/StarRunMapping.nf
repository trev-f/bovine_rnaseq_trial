process StarRunMapping {
    tag "${metadata.sampleName}"
    
    label 'star'

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
        // set reads argument based on whether sample is single- or paired-end reads
        readsArg = reads[1] ? "${reads[0]} ${reads[1]}" : "${reads[0]}"

        def args = task.ext.args ?: ''
        
        """
        STAR \
            --genomeDir ${genomeIndex} \
            --readFilesIn ${readsArg} \
            --readFilesCommand gunzip -c \
            --outFileNamePrefix ${metadata.sampleName} \
            --runThreadN ${task.cpus} \
            --outSAMtype BAM Unsorted \
            --outSAMunmapped Within \
            ${args}
        """
}
