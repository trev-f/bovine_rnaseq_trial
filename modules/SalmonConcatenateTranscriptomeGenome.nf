process SalmonConcatenateTranscriptomeGenome {
    // this script does not actually invoke Salmon, so a lighter weight container could probably be used here
    container 'quay.io/biocontainers/salmon:1.9.0--h7e5ed60_1'

    publishDir "${params.baseDirData}/salmon_cat", mode: 'copy', pattern: '*'

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