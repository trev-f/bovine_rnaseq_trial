process FullMultiQC {
    tag "FullMultiQC"

    label 'multiqc'

    label 'cpu_mid'
    label 'mem_mid'
    label 'time_low'

    publishDir "${params.baseDirReports}", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/multiqc/full",   mode: 'copy', pattern: '*multiqc_data*'

    input:
        path multiqcFiles

    output:
        path '*'
    
    script:
        """
        multiqc ${multiqcFiles}
        """
}