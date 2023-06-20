process QualimapRnaseq {
    tag "${metadata.sampleName}"

    label 'qualimap'

    label 'cpu_low'
    label 'mem_mid'

    publishDir "${params.baseDirData}/qualimap", mode: 'copy', pattern: '*'

    input:
        tuple val(metadata), path(bam), path(bai)
        path gtf

    output:
        path '*', emit: qualimapRnaseqMultiqc

    script:
        def memSize = "${(task.memory - 1.GB) as String}".replaceAll(/ GB/, "")
        log.info memSize
        def args = task.ext.args ?: ''

        """
        qualimap rnaseq \
            -bam ${bam} \
            -gtf ${gtf} \
            -outdir . \
            -outformat HTML \
            --java-mem-size=${memSize}G \
            ${args}
        """
}
