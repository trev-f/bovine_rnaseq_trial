include { cutSampleNameLaneNumber } from "../functions/cutSampleNameLaneNumber.nf"
include { reshapeGroupedLaneReads } from "../functions/reshapeGroupedLaneReads.nf"
include { ConcatenateFastq        } from "../modules/ConcatenateFastq.nf"


workflow ConcatenateLanesSWF {
    take:
        reads

    main:
        log.warn "You have selected the option to concatenate reads from different lanes. This option currently only works for single-end reads. If you have any paired-end reads, you must set parameter `skipConcatenateLanes`."

        reads
            .map { cutSampleNameLaneNumber(it) }
            .groupTuple()
            .dump(tag: "readsGroupedByLane", pretty: true)
            .map { reshapeGroupedLaneReads(it) }
            .dump(tag: "readsToConcatenate", pretty: true)
            .set { readsToConcatenate }
        
        ConcatenateFastq(
            readsToConcatenate
        )
    
    emit:
        catReads = ConcatenateFastq.out.catReads
}
