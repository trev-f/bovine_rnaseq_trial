process GTF2Bed {
    tag "${assembly}"

    container 'quay.io/biocontainers/bedparse:0.2.3--py_0'

    storeDir "${params.baseDirData}/references/${assembly}"

    input:
        val assembly
        path gtf
    
    output:
        path '*.bed12', emit: bed12
    
    script:
        """
        gunzip -c ${gtf} > annotations.gtf
        
        bedparse gtf2bed \
            annotations.gtf \
        > annotations.bed12
        """
}
