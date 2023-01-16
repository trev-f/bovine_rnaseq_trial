include { Fastp } from "${projectDir}/modules/Fastp.nf"

workflow TrimReadsSWF {
    take:
        readsRaw

    main:
        Fastp(
            readsRaw
        )

    emit:
        readsTrimmed = Fastp.out.readsTrimmed
        fastpJson    = Fastp.out.fastpJson
}