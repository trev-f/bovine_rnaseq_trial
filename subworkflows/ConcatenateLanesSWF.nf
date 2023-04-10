include { cutSampleNameLaneNumber } from "../functions/cutSampleNameLaneNumber.nf"


workflow ConcatenateLanesSWF {
    take:
        reads

    main:
        reads
            .map { cutSampleNameLaneNumber(it) }
            .groupTuple()
            .view()
}
