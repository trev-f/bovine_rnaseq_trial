nextflow.enable.dsl=2

include { ParseDesignSWF as ParseDesign } from "${projectDir}/subworkflows/ParseDesignSWF.nf"
include { TrimReadsSWF   as TrimReads   } from "${projectDir}/subworkflows/TrimReadsSWF.nf"
include { ReadsQCSWF     as ReadsQC     } from "${projectDir}/subworkflows/ReadsQCSWF.nf"
include { FullMultiQC                   } from "${projectDir}/modules/FullMultiQC.nf"


workflow {
    /*
    ---------------------------------------------------------------------
        Read design file, parse sample names, and stage reads files
    ---------------------------------------------------------------------
    */

    ParseDesign(
        file(params.design)
    )
    ch_readsRaw = ParseDesign.out.samples


    /*
    ---------------------------------------------------------------------
        Trim raw reads
    ---------------------------------------------------------------------
    */

    if (!params.skipTrimReads) {
        // Subworkflow: Trim raw reads
        TrimReads(
            ch_readsRaw
        )
        ch_readsTrimmed = TrimReads.out.readsTrimmed
    } else {
        ch_readsTrimmed = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Reads QC
    ---------------------------------------------------------------------
    */

    if (!params.skipReadsQC) {
        // Subworkflow: FastQC for raw reads
        ReadsQC(
            ch_readsRaw
        )
        ch_readsRawFQC = ReadsQC.out.raw_fqc_zip
    } else {
        ch_readsRawFQC = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Full pipeline MultiQC
    ---------------------------------------------------------------------
    */

    ch_fullMultiQC = Channel.empty()
        .concat(ch_readsRawFQC)

    FullMultiQC(
        ch_fullMultiQC.collect()
    )
}
