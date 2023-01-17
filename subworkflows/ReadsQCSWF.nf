include { FastQC as RawFastQC  } from "${projectDir}/modules/FastQC.nf"
include { FastQC as TrimFastQC } from "${projectDir}/modules/FastQC.nf"


workflow ReadsQCSWF {
    take:
        readsRaw
        readsTrimmed
    
    main:
        // run FastQC on raw reads
        if (!params.skipRawFastQC) {
            RawFastQC(
                readsRaw
            )
            ch_rawFastQCZip = RawFastQC.out.zip
        } else {
            ch_rawFastQCZip = Channel.empty()
        }

        // run FastQC on trimmed reads
        if (!params.skipTrimFastQC) {
            TrimFastQC(
                readsTrimmed
            )
            ch_trimFastQCZip = TrimFastQC.out.zip
        } else {
            ch_trimFastQCZip = Channel.empty()
        }
    
    emit:
        raw_fqc_zip  = ch_rawFastQCZip
        trim_fqc_zip = ch_trimFastQCZip
}