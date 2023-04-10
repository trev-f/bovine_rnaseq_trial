/**
 * Cut the lane number from a sample name.
 * This works for standard Illumina sample name format.
 */
def cutSampleNameLaneNumber(ArrayList reads_ch) {
    reads_ch[0].sampleName = reads_ch[0].sampleName.replaceAll(/_L\d{3}/, '')

    return reads_ch
}
