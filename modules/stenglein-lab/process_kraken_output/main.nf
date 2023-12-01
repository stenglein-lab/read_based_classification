process PROCESS_KRAKEN_OUTPUT {
    tag "all"
    label 'process_low'

    conda (params.enable_conda ? 'conda-forge::r-tidyverse=1.3.1' : null) 
    // why aren't singularity biocontainers updated to a newer tidyverse version?
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-tidyverse:1.2.1' : 
        'quay.io/biocontainers/r-tidyverse:1.2.1' }"

    input:
    path(combined_kraken_output)                                                

    output:
    // path "*.pdf" ,                    emit: plots
    path "*.not_tidy.txt" ,              emit: combined_kraken_output_non_tidy
    path "versions.yml" ,                emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def basename = combined_kraken_output.getBaseName()

    """
    # make a copy of input file so can be output to results dir
    cp $combined_kraken_output ${basename}.not_tidy.txt

    # handle output in R
    process_kraken_output.R $combined_kraken_output 
    
    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        R: \$(echo \$(R --version 2>&1))
    END_VERSIONS
    """
}
