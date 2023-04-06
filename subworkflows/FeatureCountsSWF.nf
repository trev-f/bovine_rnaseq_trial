include { SubreadFeatureCounts } from "${projectDir}/modules/SubreadFeatureCounts.nf"
include { MultiQCIntermediate as FeatureCountsMultiQC } from "${projectDir}/modules/MultiQCIntermediate.nf"

workflow FeatureCountsSWF {
    take:
        indexedBams
        annotationsGFF
        runName


    main:
        /*
        ---------------------------------------------------------------------
            Count reads in features
        ---------------------------------------------------------------------
        */
        SubreadFeatureCounts(
            indexedBams,
            annotationsGFF
        )
        ch_counts = SubreadFeatureCounts.out.counts
        ch_countsSummary = SubreadFeatureCounts.out.countsSummary


        /*
        ---------------------------------------------------------------------
            Make QC report
        ---------------------------------------------------------------------
        */
        toolLabel = "featureCounts"
        reportLabel = "${runName}_${toolLabel}"
        FeatureCountsMultiQC(
            reportLabel,
            toolLabel,
            ch_countsSummary.collect()
        )
        

    emit:
        counts        = ch_counts
        countsSummary = ch_countsSummary
}
