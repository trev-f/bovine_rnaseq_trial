process SalmonConcatenateTranscriptomeGenome {
    // this script does not actually invoke Salmon, so a lighter weight container could probably be used here
    label 'salmon'

    storeDir "${params.baseDirData}/references/${assembly}"

    input:
        val assembly
        path transcriptome
        path genome
    
    output:
        path '*gentrome.fa.gz', emit: gentrome
    
    script:
        """
        cat ${transcriptome} ${genome} > ${assembly}_gentrome.fa.gz
        """
}