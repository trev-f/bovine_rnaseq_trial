nextflow.enable.dsl=2

include { ParseDesignSWF   as ParseDesign } from "${projectDir}/subworkflows/ParseDesignSWF.nf"
include { ProcessReferencesSWF as ProcessReferences } from "${projectDir}/subworkflows/ProcessReferencesSWF.nf"
include { TrimReadsSWF     as TrimReads     } from "${projectDir}/subworkflows/TrimReadsSWF.nf"
include { ReadsQCSWF       as ReadsQC       } from "${projectDir}/subworkflows/ReadsQCSWF.nf"
include { ConcatenateLanesSWF as ConcatenateLanes } from "./subworkflows/ConcatenateLanesSWF.nf"
include { SalmonSWF        as Salmon        } from "${projectDir}/subworkflows/SalmonSWF.nf"
include { SeqtkSample                       } from "${projectDir}/modules/SeqtkSample.nf"
include { StarSWF          as Star          } from "${projectDir}/subworkflows/StarSWF.nf"
include { SamtoolsSortIndex                 } from "${projectDir}/modules/SamtoolsSortIndex.nf"
include { RnaseqQCSWF      as RnaseqQC      } from "./subworkflows/RnaseqQCSWF.nf"
include { FeatureCountsSWF as FeatureCounts } from "${projectDir}/subworkflows/FeatureCountsSWF.nf"
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
    ch_readsRaw.dump(
        tag: 'ch_readsRaw',
        pretty: true
    )


    /*
    ---------------------------------------------------------------------
        Process reference files
    ---------------------------------------------------------------------
    */
    ProcessReferences(
        params.assembly,
        params.annotationsGTF
    )
    ch_annotationsGTF   = ProcessReferences.out.annotationsGTF
    ch_annotationsGFF   = ProcessReferences.out.annotationsGFF
    ch_annotationsBED12 = ProcessReferences.out.annotationsBED12


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
    ch_readsTrimmed.dump(
        tag: 'ch_readsTrimmed',
        pretty: true
    )


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


    /*
    ---------------------------------------------------------------------
        Process reads
    ---------------------------------------------------------------------
    */
    // Set channel of reads to process for downstream steps 
    if (params.forceAlignRawReads || params.skipTrimReads) {
        ch_readsToProcess = ch_readsRaw
    } else {
        ch_readsToProcess = ch_readsTrimmed
    }
    ch_readsToProcess
        .dump(tag: 'ch_readsToProcess', pretty: true)


    if (!params.skipConcatenateLanes) {
        ConcatenateLanes(
            ch_readsToProcess
        )
        ch_readsToPseudoMap = ConcatenateLanes.out.catReads
        ch_readsToSample    = ConcatenateLanes.out.catReads
    } else {
        ch_readsToPseudoMap = ch_readsToProcess
        ch_readsToSample    = ch_readsToProcess
    }
    ch_readsToPseudoMap.dump(
        tag: 'ch_readsToPseudoMap',
        pretty: true
    )
    ch_readsToSample.dump(
        tag: 'ch_readsToSample',
        pretty: true
    )


    /*
    ---------------------------------------------------------------------
        Salmon
    ---------------------------------------------------------------------
    */
    if (!params.skipSalmon) {
        Salmon(
            params.assembly,
            file(params.transcriptome),
            file(params.genome),
            ch_readsToPseudoMap,
            runName
        )
        ch_salmonQuant = Salmon.out.salmonQuant
    } else {
        ch_salmonQuant = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Sample reads
    ---------------------------------------------------------------------
    */
    if (!params.skipSampleReadsSTAR) {
        SeqtkSample(
            ch_readsToSample,
            params.readsSampleSize
        )
        ch_readsToMap = SeqtkSample.out.sampledReads
    } else {
        ch_readsToMap = ch_readsToSample
    }
    ch_readsToMap.dump(
        tag: 'ch_readsToMap',
        pretty: true
    )


    /*
    ---------------------------------------------------------------------
        Star
    ---------------------------------------------------------------------
    */
    if (!params.skipSTAR) {
        Star(
            params.assembly,
            file(params.genome),
            ch_annotationsGTF,
            ch_readsToMap,
            runName
        )
        ch_starLogs = Star.out.logFinalOut
        ch_bams     = Star.out.bams
    } else {
        ch_starLogs = Channel.empty()
        ch_bams     = Channel.empty()
    }


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
        Perform RNA-seq specific QC
    ---------------------------------------------------------------------
    */
    if (!params.skipRnaseqQC) {
        RnaseqQC(
            ch_indexedBams,
            ch_annotationsGTF,
            runName
        )
        ch_rnaseqQCMultiQC = RnaseqQC.out.rnaseqQCMultiQC
    } else {
        ch_rnaseqQCMultiQC = Channel.empty()
    }


    /*
    ---------------------------------------------------------------------
        Count reads in genes
    ---------------------------------------------------------------------
    */
    if (!params.skipFeatureCounts) {
        FeatureCounts(
            ch_indexedBams,
            ch_annotationsGTF,
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
        .concat(ch_rnaseqQCMultiQC)
        .concat(ch_countsSummary)

    reportLabel = "${runName}"
    FullMultiQC(
        reportLabel,
        ch_fullMultiQC.collect()
    )
}
