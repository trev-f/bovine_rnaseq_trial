def reshapeGroupedLaneReads(groupedReads) {
    // make empty lists for R1 and R2
    def reads1 = [] as ArrayList
    def reads2 = [] as ArrayList

    groupedReads[1].each {
        if (it instanceof Collection) {
            reads1.add(it[0])
            reads2.add(it[1])
        } else {
            reads1.add(it)
        }
    }

    return [groupedReads[0], reads1, reads2]
}
