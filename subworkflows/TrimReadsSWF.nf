include { Fastp                               } from "${projectDir}/modules/Fastp.nf"
include { MultiQCIntermediate as FastpMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"

workflow TrimReadsSWF {
    take:
        readsRaw
        adapterFasta
        runName

    main:
        Fastp(
            readsRaw,
            adapterFasta
        )

        toolLabel = "fastp"
        reportLabel = "${runName}_${toolLabel}"
        FastpMultiQC(
            reportLabel,
            toolLabel,
            Fastp.out.fastpJson.collect()
        )

    emit:
        readsTrimmed = Fastp.out.readsTrimmed
        fastpJson    = Fastp.out.fastpJson
}