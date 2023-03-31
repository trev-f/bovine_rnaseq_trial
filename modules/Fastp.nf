process Fastp {
    tag "${metadata.sampleName}"

    label 'fastp'

    label 'cpu_mid'
    label 'mem_mid'
    
    publishDir "${params.baseDirData}/reads/trimmed", mode: 'copy', pattern: '*.fastq.gz'

    input:
        tuple val(metadata), file(reads)
    
    output:
        tuple val(metadata), path('*.fastq.gz'), emit: readsTrimmed
        path ('*fastp.json'), emit: fastpJson
    
    script:
        if (reads[1]) {
            """
            fastp \
                --thread ${task.cpus} \
                -i ${reads[0]} \
                -I ${reads[1]} \
                -o ${metadata.sampleName}_trimmed_R1.fastq.gz \
                -O ${metadata.sampleName}_trimmed_R2.fastq.gz \
                -j ${metadata.sampleName}_fastp.json
            """
        }
        else {
            """
            fastp \
                --thread ${task.cpus} \
                -i ${reads[0]} \
                -o ${metadata.sampleName}_trimmed_R1.fastq.gz \
                -j ${metadata.sampleName}_fastp.json
            """
        }
}
