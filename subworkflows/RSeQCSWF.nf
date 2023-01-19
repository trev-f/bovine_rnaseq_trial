include { GTF2Bed } from "${projectDir}/modules/GTF2Bed.nf"
include { RSeQCGeneBodyCoverage } from "${projectDir}/modules/RSeQCGeneBodyCoverage.nf"
include { MultiQCIntermediate as RSeQCMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"

workflow RSeQCSWF {
    take:
        assembly
        annotationsGTF
        indexedBams

    main:
        /*
        ---------------------------------------------------------------------
            Convert annotations from GTF to Bed12
        ---------------------------------------------------------------------
        */
        GTF2Bed(
            assembly,
            annotationsGTF
        )
        ch_annotationsBed12 = GTF2Bed.out.bed12


        /*
        ---------------------------------------------------------------------
            Calculate reads coverage over gene bodies
        ---------------------------------------------------------------------
        */
        RSeQCGeneBodyCoverage(
            indexedBams,
            ch_annotationsBed12
        )
        ch_geneBodyCoverage = RSeQCGeneBodyCoverage.out.geneBodyCoverage


        /*
        ---------------------------------------------------------------------
            Make QC report
        ---------------------------------------------------------------------
        */
        ch_rseqcMultiQC = Channel.empty()
            .concat(ch_geneBodyCoverage)
        
        RSeQCMultiQC(
            'rseqc',
            ch_rseqcMultiQC.collect()
        )
}