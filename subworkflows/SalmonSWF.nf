include { SalmonExtractDecoys                  } from "${projectDir}/modules/SalmonExtractDecoys.nf"
include { SalmonConcatenateTranscriptomeGenome } from "${projectDir}/modules/SalmonConcatenateTranscriptomeGenome.nf"
include { SalmonIndex                          } from "${projectDir}/modules/SalmonIndex.nf"
include { SalmonQuantMappingMode               } from "${projectDir}/modules/SalmonQuantMappingMode.nf"
include { MultiQCIntermediate as SalmonMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"

workflow SalmonSWF {
    take:
        assembly
        transcriptome
        genome
        reads
    
    main:
        /*
        ---------------------------------------------------------------------
            Prepare metadata
        ---------------------------------------------------------------------
        */
        SalmonExtractDecoys(
            assembly,
            genome
        )
        ch_decoys = SalmonExtractDecoys.out.decoys

        SalmonConcatenateTranscriptomeGenome(
            assembly,
            transcriptome,
            genome
        )
        ch_gentrome = SalmonConcatenateTranscriptomeGenome.out.gentrome

        /*
        ---------------------------------------------------------------------
            Index transcriptome
        ---------------------------------------------------------------------
        */
        SalmonIndex(
            assembly,
            ch_gentrome,
            ch_decoys
        )
        ch_salmonIndex = SalmonIndex.out.salmonIndex


        /*
        ---------------------------------------------------------------------
            Map and quantify reads
        ---------------------------------------------------------------------
        */
        SalmonQuantMappingMode(
            ch_salmonIndex,
            params.salmonLibType,
            reads
        )
        ch_salmonQuant = SalmonQuantMappingMode.out.transcriptsQuant


        /*
        ---------------------------------------------------------------------
            Make QC report
        ---------------------------------------------------------------------
        */
        SalmonMultiQC(
            'salmon',
            ch_salmonQuant.collect()
        )
    emit:
        salmonQuant = ch_salmonQuant
}
