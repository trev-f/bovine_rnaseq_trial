nextflow.enable.dsl=2

include { ParseDesignSWF   as ParseDesign } from "${projectDir}/subworkflows/ParseDesignSWF.nf"
include { TrimReadsSWF     as TrimReads     } from "${projectDir}/subworkflows/TrimReadsSWF.nf"
include { ReadsQCSWF       as ReadsQC       } from "${projectDir}/subworkflows/ReadsQCSWF.nf"
include { SalmonSWF        as Salmon        } from "${projectDir}/subworkflows/SalmonSWF.nf"
include { SeqtkSample                       } from "${projectDir}/modules/SeqtkSample.nf"
include { StarSWF          as Star          } from "${projectDir}/subworkflows/StarSWF.nf"
include { SamtoolsSortIndex                 } from "${projectDir}/modules/SamtoolsSortIndex.nf"
include { FeatureCountsSWF as FeatureCounts } from "${projectDir}/subworkflows/FeatureCountsSWF.nf"
include { RSeQCSWF         as RSeQC         } from "${projectDir}/subworkflows/RSeQCSWF.nf"
include { FullMultiQC                       } from "${projectDir}/modules/FullMultiQC.nf"


runName = params.runName ? "${params.runName}_${workflow.runName}" : "${workflow.runName}"

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
            ch_readsRaw,
            file(params.adapterFasta),
            runName
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
            ch_readsTrimmed,
            runName
        )
        ch_readsRawFQC     = ReadsQC.out.raw_fqc_zip
        ch_readsTrimmedFQC = ReadsQC.out.trim_fqc_zip
    } else {
        ch_readsRawFQC     = Channel.empty()
        ch_readsTrimmedFQC = Channel.empty()
    }

    // Set channel of reads to align 
    if (!params.forceAlignRawReads) {
        if (!params.skipTrimReads) {
            ch_readsToAlign = ch_readsTrimmed
        } else {
            ch_readsToAlign = ch_readsRaw
        }
    } else {
        ch_readsToAlign = ch_readsRaw
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
        ch_readsToAlign,
        runName
    )
    ch_salmonQuant = Salmon.out.salmonQuant


    /*
    ---------------------------------------------------------------------
        Sample reads
    ---------------------------------------------------------------------
    */

    SeqtkSample(
        ch_readsToAlign,
    
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
        ch_readsToAlign,
        runName
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
        ch_indexedBams,
        runName
    )
    ch_rseqcMultiQC   = RSeQC.out.rseqcMultiQC
    ch_annotationsGFF = RSeQC.out.annotationsGFF


    /*
    ---------------------------------------------------------------------
        Count reads in genes
    ---------------------------------------------------------------------
    */
    if (!params.skipFeatureCounts) {
        FeatureCounts(
            ch_indexedBams,
            ch_annotationsGFF,
            runName
        )
        ch_counts        = FeatureCounts.out.counts
        ch_countsSummary = FeatureCounts.out.countsSummary
    } else {
        ch_counts        = Channel.empty()
        ch_countsSummary = Channel.empty()
    }


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
        .concat(ch_rseqcMultiQC)
        .concat(ch_countsSummary)

    reportLabel = "${runName}"
    FullMultiQC(
        reportLabel,
        ch_fullMultiQC.collect()
    )
}
