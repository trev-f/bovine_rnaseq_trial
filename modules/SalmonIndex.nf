process SalmonIndex {
    container 'quay.io/biocontainers/salmon:1.9.0--h7e5ed60_1'

    publishDir "${params.baseDirData}/salmon_index", mode: 'copy', pattern: '*'

    input:
        val assembly
        path gentrome
        path decoys

    output:
        path '*', emit: salmonIndex
    
    script:
        """
        salmon index \
            --transcripts ${gentrome} \
            --decoys ${decoys} \
            --index ${assembly}_salmon_index \
            --threads ${task.cpus}
        """
}