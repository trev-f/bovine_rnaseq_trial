process MultiQCIntermediate {
    tag "${toolLabel}_MultiQC"

    label 'multiqc'

    label 'mem_mid'
    label 'time_low'

    publishDir "${params.baseDirReports}/multiqc/${toolLabel}", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/multiqc/${toolLabel}",   mode: 'copy', pattern: '*multiqc_data*'

    input:
        val reportLabel
        val toolLabel
        path multiqcFiles

    output:
        path '*'
    
    script:
        """
        multiqc \
            -n ${reportLabel}_multiqc_report \
            ${multiqcFiles}
        """
}
