process GunzipGTF {
    tag "${assembly}"

    label 'base'

    input:
        val assembly
        path gtf
    
    output:
        path '*.gtf', emit: gtf
    
    script:
        """
        gunzip --force ${gtf}
        """
}
