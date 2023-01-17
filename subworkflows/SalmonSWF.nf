include { SalmonExtractDecoys                  } from "${projectDir}/modules/SalmonExtractDecoys.nf"
include { SalmonConcatenateTranscriptomeGenome } from "${projectDir}/modules/SalmonConcatenateTranscriptomeGenome.nf"

workflow SalmonSWF {
    take:
        assembly
        transcriptome
        genome
    
    main:
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
}
