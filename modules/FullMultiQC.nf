process FullMultiQC {
    tag "FullMultiQC"

    label 'cpu_mid'
    label 'mem_mid'
    label 'time_low'

    container 'ewels/multiqc:v1.11'

    publishDir "${params.baseDirReports}", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}",   mode: 'copy', pattern: '*multiqc_data*'

    input:
        path multiqcFiles

    output:
        path '*'
    
    script:
        """
        multiqc ${multiqcFiles}
        """
}