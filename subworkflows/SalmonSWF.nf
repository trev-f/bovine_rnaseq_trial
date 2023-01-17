include { SalmonExtractDecoys } from "${projectDir}/modules/SalmonExtractDecoys.nf"

workflow SalmonSWF {
    take:
        assembly
        genome
    
    main:
        SalmonExtractDecoys(
            assembly,
            genome
        )
        ch_decoys = SalmonExtractDecoys.out.decoys
}
