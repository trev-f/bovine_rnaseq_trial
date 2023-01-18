include { Fastp                               } from "${projectDir}/modules/Fastp.nf"
include { MultiQCIntermediate as FastpMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"

workflow TrimReadsSWF {
    take:
        readsRaw

    main:
        Fastp(
            readsRaw
        )

        FastpMultiQC(
            'fastp',
            Fastp.out.fastpJson.collect()
        )

    emit:
        readsTrimmed = Fastp.out.readsTrimmed
        fastpJson    = Fastp.out.fastpJson
}