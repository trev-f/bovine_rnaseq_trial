nextflow.enable.dsl=2

include { ParseDesignSWF as ParseDesign } from "${projectDir}/subworkflows/ParseDesignSWF.nf"
include { TrimReadsSWF   as TrimReads   } from "${projectDir}/subworkflows/TrimReadsSWF.nf"
include { ReadsQCSWF     as ReadsQC     } from "${projectDir}/subworkflows/ReadsQCSWF.nf"
include { SalmonSWF      as Salmon      } from "${projectDir}/subworkflows/SalmonSWF.nf"
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
        ch_fastpJson    = TrimReads.out.fastpJson
    } else {
        ch_readsTrimmed = Channel.empty()
        ch_fastpJson    = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Reads QC
    ---------------------------------------------------------------------
    */

    if (!params.skipReadsQC) {
        // Subworkflow: FastQC for raw reads
        ReadsQC(
            ch_readsRaw,
            ch_readsTrimmed
        )
        ch_readsRawFQC     = ReadsQC.out.raw_fqc_zip
        ch_readsTrimmedFQC = ReadsQC.out.trim_fqc_zip
    } else {
        ch_readsRawFQC     = Channel.empty()
        ch_readsTrimmedFQC = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Salmon
    ---------------------------------------------------------------------
    */

    Salmon(
        params.assembly,
        file(params.transcriptome),
        file(params.genome)
    )

    /*
    ---------------------------------------------------------------------
        Full pipeline MultiQC
    ---------------------------------------------------------------------
    */

    ch_fullMultiQC = Channel.empty()
        .concat(ch_fastpJson)
        .concat(ch_readsRawFQC)
        .concat(ch_readsTrimmedFQC)

    FullMultiQC(
        ch_fullMultiQC.collect()
    )
}
