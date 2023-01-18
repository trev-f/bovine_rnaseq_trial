process MultiQCIntermediate {
    tag "${reportLabel}_MultiQC"

    label 'mem_mid'
    label 'time_low'

    container 'ewels/multiqc:v1.11'

    publishDir "${params.baseDirReports}/multiqc/${reportLabel}", mode: 'copy', pattern: '*.html'
    publishDir "${params.baseDirData}/multiqc/${reportLabel}",   mode: 'copy', pattern: '*multiqc_data*'

    input:
        val reportLabel
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
