include { FastQC              as RawFastQC            } from "${projectDir}/modules/FastQC.nf"
include { FastQC              as TrimFastQC           } from "${projectDir}/modules/FastQC.nf"
include { MultiQCIntermediate as RawFastQCMultiQC     } from "${projectDir}/modules/MultiQCIntermediate.nf"
include { MultiQCIntermediate as TrimmedFastQCMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"


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

        // summarize raw FastQC in a MultiQC report
        RawFastQCMultiQC(
            'raw_fastqc',
            ch_rawFastQCZip.collect()
        )


        // run FastQC on trimmed reads
        if (!params.skipTrimFastQC) {
            TrimFastQC(
                readsTrimmed
            )
            ch_trimFastQCZip = TrimFastQC.out.zip
        } else {
            ch_trimFastQCZip = Channel.empty()
        }

        // summarize trimmed FastQC in a MultiQC report
        TrimmedFastQCMultiQC(
            'trimmed_fastqc',
            ch_trimFastQCZip.collect()
        )

    emit:
        raw_fqc_zip  = ch_rawFastQCZip
        trim_fqc_zip = ch_trimFastQCZip
}