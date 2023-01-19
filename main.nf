nextflow.enable.dsl=2

include { ParseDesignSWF as ParseDesign } from "${projectDir}/subworkflows/ParseDesignSWF.nf"
include { TrimReadsSWF   as TrimReads   } from "${projectDir}/subworkflows/TrimReadsSWF.nf"
include { ReadsQCSWF     as ReadsQC     } from "${projectDir}/subworkflows/ReadsQCSWF.nf"
include { SalmonSWF      as Salmon      } from "${projectDir}/subworkflows/SalmonSWF.nf"
include { SeqtkSample                   } from "${projectDir}/modules/SeqtkSample.nf"
include { StarSWF        as Star        } from "${projectDir}/subworkflows/StarSWF.nf"
include { SamtoolsSortIndex             } from "${projectDir}/modules/SamtoolsSortIndex.nf"
include {RSeQCSWF        as RSeQC       } from "${projectDir}/subworkflows/RSeQCSWF.nf"
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
        file(params.genome),
        ch_readsTrimmed
    )
    ch_salmonQuant = Salmon.out.salmonQuant


    /*
    ---------------------------------------------------------------------
        Sample reads
    ---------------------------------------------------------------------
    */

    SeqtkSample(
        ch_readsTrimmed,
    
        params.readsSampleSize
    )
    ch_sampledReads = SeqtkSample.out.sampledReads


    /*
    ---------------------------------------------------------------------
        Star
    ---------------------------------------------------------------------
    */
    Star(
        params.assembly,
        file(params.genome),
        file(params.annotationsGTF),
        ch_sampledReads
    )
    ch_starLogs = Star.out.logFinalOut
    ch_bams     = Star.out.bams


    /*
    ---------------------------------------------------------------------
        Sort and index bams
    ---------------------------------------------------------------------
    */
    SamtoolsSortIndex(
        ch_bams
    )
    ch_indexedBams = SamtoolsSortIndex.out.bamIndexed


    /*
    ---------------------------------------------------------------------
        Sort and index bams
    ---------------------------------------------------------------------
    */
    RSeQC(
        params.assembly,
        params.annotationsGTF,
        ch_indexedBams
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
        .concat(ch_salmonQuant)
        .concat(ch_starLogs)

    FullMultiQC(
        ch_fullMultiQC.collect()
    )
}
