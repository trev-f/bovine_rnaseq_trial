include { QualimapRnaseq } from "../modules/QualimapRnaseq.nf"


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
}
