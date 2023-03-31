process SalmonIndex {
    label 'salmon'

    label 'cpu_mid'
    label 'mem_high'

    storeDir "${params.baseDirData}/references/${assembly}/salmon_index"

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