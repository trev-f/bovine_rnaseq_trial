include { StarGenerateGenomeIndexes          } from "${projectDir}/modules/StarGenerateGenomeIndexes.nf"
include { cutSampleNameLaneNumber            } from "../functions/MergeLanes.nf"
include { StarRunMapping                     } from "${projectDir}/modules/StarRunMapping.nf"
include { MultiQCIntermediate as StarMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"

workflow StarSWF {
    take:
        assembly
        genome
        annotationsGTF
        reads
        runName
    
    main:
        /*
        ---------------------------------------------------------------------
            Index transcriptome
        ---------------------------------------------------------------------
        */
        StarGenerateGenomeIndexes(
            assembly,
            genome,
            annotationsGTF
        )
        ch_starIndex = StarGenerateGenomeIndexes.out.index


        /*
        ---------------------------------------------------------------------
            Run mapping job
        ---------------------------------------------------------------------
        */
        if (params.mergeLanes) {
            reads
                .map { cutSampleNameLaneNumber(it) }
                .view()
        }
        StarRunMapping(
            ch_starIndex,
            reads
        )
        ch_mappedBAMs = StarRunMapping.out.bam
        ch_logFinalOut = StarRunMapping.out.logFinalOut


        /*
        ---------------------------------------------------------------------
            Make QC report
        ---------------------------------------------------------------------
        */
        toolLabel = "star"
        reportLabel = "${runName}_${toolLabel}"
        StarMultiQC(
            reportLabel,
            toolLabel,
            ch_logFinalOut.collect()
        )
    
    emit:
        logFinalOut = ch_logFinalOut
        bams        = ch_mappedBAMs
}
