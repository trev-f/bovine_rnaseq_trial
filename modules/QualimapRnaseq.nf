process QualimapRnaseq {
    tag "${metadata.sampleName}"

    label 'qualimap'

    label 'mem_high'

    publishDir "${params.baseDirData}/qualimap", mode: 'copy', pattern: '*'

    input:
        tuple val(metadata), path(bam), path(bai)
        path gtf

    output:
        path '*', emit: qualimapRnaseqMultiqc

    script:
        def memSize = "${(task.memory - 1.GB) as String}".replaceAll(/ GB/, "")
        def args = task.ext.args ?: ''

        """
        export JAVA_OPTS="-Djava.io.tmpdir=\${PWD}"

        qualimap rnaseq \
            -bam ${bam} \
            -gtf ${gtf} \
            -outdir . \
            -outformat HTML \
            --java-mem-size=${memSize}G \
            ${args}
        """
}
