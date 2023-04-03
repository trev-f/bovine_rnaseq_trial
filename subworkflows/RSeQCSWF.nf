include { GTF2GFF } from "${projectDir}/modules/GTF2GFF.nf"
include { GFF2Bed } from "${projectDir}/modules/GFF2Bed.nf"
include { RSeQCGeneBodyCoverage } from "${projectDir}/modules/RSeQCGeneBodyCoverage.nf"
include { RSeQCReadDistribution } from "${projectDir}/modules/RSeQCReadDistribution.nf"
include { MultiQCIntermediate as RSeQCMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"

workflow RSeQCSWF {
    take:
        assembly
        annotationsGTF
        indexedBams
        runName

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
        
        toolLabel = "rseqc"
        reportLabel = "${runName}_${toolLabel}"
        RSeQCMultiQC(
            reportLabel,
            toolLabel,
            ch_rseqcMultiQC.collect()
        )

    emit:
        rseqcMultiQC = ch_rseqcMultiQC
}