include { GTF2GFF } from "${projectDir}/modules/GTF2GFF.nf"
include { GFF2Bed } from "${projectDir}/modules/GFF2Bed.nf"


workflow ProcessReferencesSWF {
    take:
        assembly
        annotationsGTF

    main:
        /*
        ---------------------------------------------------------------------
            Convert annotations from GTF to Bed12
        ---------------------------------------------------------------------
        */
        GTF2GFF(
            assembly,
            annotationsGTF
        )
        ch_annotationsGFF = GTF2GFF.out.gff

        GFF2Bed(
            assembly,
            annotationsGTF
        )
        ch_annotationsBed12 = GFF2Bed.out.bed12

    emit:
        annotationsGFF   = ch_annotationsGFF
        annotationsBED12 = ch_annotationsBed12
}
