include { FastQC as RawFastQC } from "${projectDir}/modules/FastQC.nf"


workflow ReadsQCSWF {
    take:
        readsRaw
    
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
    
    emit:
        raw_fqc_zip  = ch_rawFastQCZip
}