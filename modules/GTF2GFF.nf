process GTF2GFF {
    tag "${assembly}"

    label 'agat'

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
