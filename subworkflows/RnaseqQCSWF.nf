include { QualimapRnaseq } from "../modules/QualimapRnaseq.nf"
include { MultiQCIntermediate as RnaseqQCMultiQC } from "../modules/MultiQCIntermediate.nf"


workflow RnaseqQCSWF {
    take:
        indexedBams
        annotationsGTF
        runName
    
    main:
        /*
        ---------------------------------------------------------------------
            Run qualimap rnaseq
        ---------------------------------------------------------------------
        */
        QualimapRnaseq(
            indexedBams,
            annotationsGTF
        )
        ch_qualimapRnaseqMultiqc = QualimapRnaseq.out.qualimapRnaseqMultiqc


        /*
        ---------------------------------------------------------------------
            Make QC report
        ---------------------------------------------------------------------
        */
        ch_rnaseqQCMultiQC = Channel.empty()
            .concat(ch_qualimapRnaseqMultiqc)

        toolLabel = "rnaseqqc"
        reportLabel = "${runName}_${toolLabel}"
        RnaseqQCMultiQC(
            reportLabel,
            toolLabel,
            ch_rnaseqQCMultiQC.collect()
        )
}
