process SalmonExtractDecoys {
    // this script does not actually invoke Salmon, so a lighter weight container could probably be used here
    label 'salmon'

    storeDir "${params.baseDirData}/references/${assembly}"

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
