include { SalmonDecoy } from "${projectDir}/modules/SalmonDecoy.nf"

workflow SalmonSWF {
    take:
        assembly
        genome
    
    main:
        SalmonDecoy(
            assembly,
            genome
        )
        ch_decoys = SalmonDecoy.out.decoys
}
