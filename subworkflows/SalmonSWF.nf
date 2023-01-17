include { SalmonExtractDecoys                  } from "${projectDir}/modules/SalmonExtractDecoys.nf"
include { SalmonConcatenateTranscriptomeGenome } from "${projectDir}/modules/SalmonConcatenateTranscriptomeGenome.nf"
include { SalmonIndex                          } from "${projectDir}/modules/SalmonIndex.nf"
include { SalmonQuantMappingMode               } from "${projectDir}/modules/SalmonQuantMappingMode.nf"

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
        ch_salmonMeta = SalmonQuantMappingMode.out.salmonMeta
        ch_salmonFLD = SalmonQuantMappingMode.out.salmonFLD
    
    emit:
        salmonMeta = ch_salmonMeta
        salmonFLD = ch_salmonFLD
}
