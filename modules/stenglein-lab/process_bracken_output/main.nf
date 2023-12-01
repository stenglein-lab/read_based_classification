process PROCESS_BRACKEN_OUTPUT {
    tag "all"
    label 'process_low'

    conda (params.enable_conda ? 'conda-forge::r-tidyverse=1.3.1' : null) 
    // why aren't singularity biocontainers updated to a newer tidyverse version?
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-tidyverse:1.2.1' : 
        'quay.io/biocontainers/r-tidyverse:1.2.1' }"

    input:
    path(combined_bracken_output)                                                

    output:
    // path "*.pdf" ,                       emit: plots
    path "versions.yml" ,                emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def basename = combined_bracken_output.getBaseName()

    """
    # make a copy of input file so can be output to results dir
    cp $combined_bracken_output ${basename}.tidy.txt

    # handle output in R
    process_bracken_output.R $combined_bracken_output 
    
    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        R: \$(echo \$(R --version 2>&1))
    END_VERSIONS
    """
}
