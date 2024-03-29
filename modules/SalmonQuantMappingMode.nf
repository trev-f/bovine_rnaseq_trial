process SalmonQuantMappingMode {
    tag "${metadata.sampleName}"

    label 'salmon'

    label 'cpu_high'
    label 'mem_big'
    label 'time_mid'

    publishDir "${params.baseDirData}/salmon_transcripts_quant", mode: 'copy', pattern: '*'

    input:
        path salmonIndex
        val libType
        tuple val(metadata), file(reads)

    output:
        path '*', emit: transcriptsQuant

    script:
        // auto detect library type if it is not already specified
        libType = libType ?: 'A'

        def args = task.ext.args ?: ''

        // set reads argument based on whether sample is single- or paired-end reads
        if (reads[1]) {
            log.debug "${metadata.sampleName} is paired-end reads"
            readsArg = "--mates1 ${reads[0]} --mates2 ${reads[1]}"
        } else {
            log.debug "${metadata.sampleName} is single-end reads"
            readsArg = "--unmatedReads ${reads[0]}"
        }
        log.debug "Reads argument for ${metadata.sampleName}: ${readsArg}"
        

        """
        salmon quant \
            --libType ${libType} \
            --index ${salmonIndex} \
            ${readsArg} \
            --output ${metadata.sampleName}_transcripts_quant \
            --threads ${task.cpus} \
            --validateMappings \
            --writeUnmappedNames \
            ${args}
        """
}
