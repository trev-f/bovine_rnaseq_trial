include { FastQC              as RawFastQC            } from "${projectDir}/modules/FastQC.nf"
include { FastQC              as TrimFastQC           } from "${projectDir}/modules/FastQC.nf"
include { MultiQCIntermediate as RawFastQCMultiQC     } from "${projectDir}/modules/MultiQCIntermediate.nf"
include { MultiQCIntermediate as TrimmedFastQCMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"


workflow ReadsQCSWF {
    take:
        readsRaw
        readsTrimmed
        runName
    
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
        toolLabel = 'fastqc_raw'
        reportLabel = "${runName}_${toolLabel}"
        RawFastQCMultiQC(
            reportLabel,
            toolLabel,
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
        toolLabel = 'fastqc_trimmed'
        reportLabel = "${runName}_${toolLabel}"
        TrimmedFastQCMultiQC(
            reportLabel,
            toolLabel,
            ch_trimFastQCZip.collect()
        )

    emit:
        raw_fqc_zip  = ch_rawFastQCZip
        trim_fqc_zip = ch_trimFastQCZip
}