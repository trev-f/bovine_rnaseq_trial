process SalmonDecoy {
    // this script does not actually invoke Salmon, so a lighter weight container could probably be used here
    container 'quay.io/biocontainers/salmon:1.9.0--h7e5ed60_1'

    publishDir "${params.baseDirData}/salmon_decoy", mode: 'copy', pattern: '*'

    input:
        val assembly
        path genome

    output:
        path '*decoys.txt', emit: decoys

    script:
        """
        # extract names of genome targets
        grep '^>' <(gunzip -c ${genome}) \
        | cut -d " " -f 1 \
        | sed 's/>//g' \
        > ${assembly}_decoys.txt
        """
}
