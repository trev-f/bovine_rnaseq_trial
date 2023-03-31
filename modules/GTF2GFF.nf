process GTF2GFF {
    tag "${assembly}"

    container 'quay.io/biocontainers/agat:1.0.0--pl5321hdfd78af_0'

    storeDir "${params.baseDirData}/references/${assembly}"

    input:
        val assembly
        path gtf
    
    output:
        path '*.gff', emit: gff
    
    script:
        """
        # convert GTF to GFF3 format
        agat_convert_sp_gxf2gxf.pl \
            -g ${gtf} \
            -o annotations.gff
        """
}
