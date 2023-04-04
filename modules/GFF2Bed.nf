process GFF2Bed {
    tag "${assembly}"

    label 'agat'

    label 'mem_high'

    storeDir "${params.baseDirData}/references/${assembly}"

    input:
        val assembly
        path gff
    
    output:
        path '*.bed12', emit: bed12
    
    script:
        """
        # convert GFF3 to bed12
        agat_convert_sp_gff2bed.pl \
            --gff ${gff} \
        # If a gene does not have a level 2 child (mRNA or transcript),
        # AGAT writes the feature to bed12 file but leaves column 7 and 8 as "." chracters.
        # This causes RSeQC read_distribution.py to fail as it expects these columns to be integers.
        # I prefer leaving these features in, so here I force columns 7 and 8 to be the same as start and stop coordinates
        # since this is how genes with a level 2 feature are written.
        \ | awk 'BEGIN{FS=OFS="\\t"} \$7 = \$2' \
        | awk 'BEGIN{FS=OFS="\\t"} \$8 = \$3' > annotations.bed12
        """
}
