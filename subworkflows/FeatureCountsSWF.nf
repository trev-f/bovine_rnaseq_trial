include { SubreadFeatureCounts } from "${projectDir}/modules/SubreadFeatureCounts.nf"

workflow FeatureCountsSWF {
    take:
        indexedBams
        annotationsGFF


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


    emit:
        counts        = ch_counts
        countsSummary = ch_countsSummary
}
