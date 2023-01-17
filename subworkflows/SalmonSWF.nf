include { SalmonExtractDecoys                  } from "${projectDir}/modules/SalmonExtractDecoys.nf"
include { SalmonConcatenateTranscriptomeGenome } from "${projectDir}/modules/SalmonConcatenateTranscriptomeGenome.nf"
include { SalmonIndex                          } from "${projectDir}/modules/SalmonIndex.nf"

workflow SalmonSWF {
    take:
        assembly
        transcriptome
        genome
    
    main:
        /*
        ---------------------------------------------------------------------
            prepare metadata
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
            prepare metadata
        ---------------------------------------------------------------------
        */
        SalmonIndex(
            assembly,
            ch_gentrome,
            ch_decoys
        )
}
