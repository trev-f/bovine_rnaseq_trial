process SalmonQuantMappingMode {
    tag "${metadata.sampleName}"

    container 'quay.io/biocontainers/salmon:1.9.0--h7e5ed60_1'

    label 'cpu_high'
    label 'mem_high'
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

        """
        salmon quant \
            --libType ${libType} \
            --index ${salmonIndex} \
            --mates1 ${reads[0]} \
            --mates2 ${reads[1]} \
            --output ${metadata.sampleName}_transcripts_quant \
            --threads ${task.cpus} \
            --validateMappings \
            --writeMappings=${metadata.sampleName}_transcripts_mappings.txt \
            --writeUnmappedNames
        """
}
