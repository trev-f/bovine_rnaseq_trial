include { GTF2Bed } from "${projectDir}/modules/GTF2Bed.nf"
include { RSeQCGeneBodyCoverage } from "${projectDir}/modules/RSeQCGeneBodyCoverage.nf"
include { RSeQCReadDistribution } from "${projectDir}/modules/RSeQCReadDistribution.nf"
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
            Calculate distribution of reads over genome features
        ---------------------------------------------------------------------
        */
        RSeQCReadDistribution(
            indexedBams,
            ch_annotationsBed12
        )
        ch_readDistribution = RSeQCReadDistribution.out.readDistribution


        /*
        ---------------------------------------------------------------------
            Make QC report
        ---------------------------------------------------------------------
        */
        ch_rseqcMultiQC = Channel.empty()
            .concat(ch_geneBodyCoverage)
            .concat(ch_readDistribution)
        
        RSeQCMultiQC(
            'rseqc',
            ch_rseqcMultiQC.collect()
        )
}