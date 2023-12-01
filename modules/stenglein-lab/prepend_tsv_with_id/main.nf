process PREPEND_TSV_WITH_ID {
    tag "$tsv"
    label 'process_low'

    // we just need a base linux environment for this module
    // which is an assumption of the nextflow pipeline

    input:
    tuple val(meta), path(tsv)                                                
    // val (skip_first_line)
    // val (prefix)

    output:
    tuple val(meta), path ("*.prepended.tsv") , emit: tsv
    path ("*prepended.tsv") ,                   emit: tsv_file
    path "versions.yml" ,                       emit: versions

    when:
    task.ext.when == null || task.ext.when

    shell:

    // def prefix   = task.ext.prefix ?: "${meta.id}"                                
    // prepend tsv output with a column containing sample ID (from meta.id)
    // on all lines except first line, which is presumed to be a header
    // in first header line, insert a # comment character instead of the ID as first column
    //awk '{ if (NR==1) { print "#\t" $0 } else {print "!{meta.id}" "\t" $0}  }' !{tsv} > "!{tsv}.prepended.tsv"
    '''
    awk '{ print "!{meta.id}" "\t" $0 }' !{tsv} > "!{tsv}.prepended.tsv"
    
    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
    END_VERSIONS
    '''
}

