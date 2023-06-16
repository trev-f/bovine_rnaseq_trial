include { cutSampleNameLaneNumber } from "../functions/cutSampleNameLaneNumber.nf"
include { reshapeGroupedLaneReads } from "../functions/reshapeGroupedLaneReads.nf"
include { ConcatenateFastq        } from "../modules/ConcatenateFastq.nf"


workflow ConcatenateLanesSWF {
    take:
        reads

    main:
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
