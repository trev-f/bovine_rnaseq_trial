include { StarGenerateGenomeIndexes          } from "${projectDir}/modules/StarGenerateGenomeIndexes.nf"
include { StarRunMapping                     } from "${projectDir}/modules/StarRunMapping.nf"
include { MultiQCIntermediate as StarMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"

workflow StarSWF {
    take:
        assembly
        genome
        annotationsGTF
        reads
    
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
        StarMultiQC(
            'star',
            ch_logFinalOut.collect()
        )
}
