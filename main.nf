#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { CLASSIFY_READS } from './subworkflows/stenglein-lab/classify_reads.nf'

//
// WORKFLOW: Run main analysis pipeline
//
workflow MAIN_WORKFLOW {
  CLASSIFY_READS(params.fastq_dir, params.fastq_pattern)
}

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    MAIN_WORKFLOW ()
}
