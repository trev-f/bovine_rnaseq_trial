def reshapeGroupedLaneReads(groupedReads) {
    // make empty lists for R1 and R2
    def reads1 = [] as ArrayList
    def reads2 = [] as ArrayList

    println groupedReads[1]
    println groupedReads[1].getClass()

    groupedReads[1].each {
        println "Looking at collection of reads:"
        println it
        println it.getClass()

        if (it instanceof Collection) {
            println "Looking into read pairs"

            reads1.add(it[0])
            reads2.add(it[1])

            it.each {
                println it
                println it.getClass()
            }
        } else {
            println "Reads must be single end"

            reads1.add(it)
        }
    }

    println "reads1: ${reads1}"
    println "reads2: ${reads2}"

    return [groupedReads[0], reads1, reads2]
}
