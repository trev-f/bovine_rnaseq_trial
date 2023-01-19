include { GTF2Bed } from "${projectDir}/modules/GTF2Bed.nf"

workflow RSeQCSWF {
    take:
        assembly
        annotationsGTF

    main:
        GTF2Bed(
            assembly,
            annotationsGTF
        )
}