process StarGenerateGenomeIndexes {
    tag "${assembly}"
    
    label 'star'

    label 'cpu_high'
    label 'mem_huge'
    label 'time_mid'

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