process StarGenerateGenomeIndexes {
    container 'quay.io/biocontainers/star:2.7.10a--h9ee0642_0'

    label 'cpu_high'
    label 'mem_high'

    storeDir "${params.baseDirData}/references/${assembly}"

    input:
        val assembly
        path genome
        path annotationsGTF
    
    output:
        path 'star_index', emit: index
    
    script:
        """
        gunzip -c ${genome} > genome.fasta
        gunzip -c ${annotationsGTF} > annotations.gtf
        mkdir star_index
        STAR \
            --runMode genomeGenerate \
            --genomeFastaFiles genome.fasta \
            --sjdbGTFfile annotations.gtf \
            --sjdbOverhang 100 \
            --genomeDir star_index \
            --runThreadN ${task.cpus}
        """
}