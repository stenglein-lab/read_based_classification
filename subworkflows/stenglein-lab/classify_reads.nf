include { MARSHAL_FASTQ               } from '../../subworkflows/stenglein-lab/marshal_fastq'
include { PREPROCESS_READS            } from '../../subworkflows/stenglein-lab/preprocess_reads'

include { MULTIQC  as MULTIQC_PRE     } from '../../modules/nf-core/multiqc/main' 

include { KRAKEN2_WORKFLOW            } from '../../subworkflows/stenglein-lab/kraken2'

include { PROCESS_KRAKEN_OUTPUT       } from '../../modules/stenglein-lab/process_kraken_output/main'

// include { MULTIQC  as MULTIQC_PRE     }              from '../../modules/nf-core/multiqc/main' 
// include { CUSTOM_DUMPSOFTWAREVERSIONS }              from '../../modules/nf-core/custom/dumpsoftwareversions/main'

// include { COUNT_FASTQ as COUNT_FASTQ_POST_COLLAPSE } from '../../modules/stenglein-lab/count_fastq/main'

// include { SAVE_OUTPUT_FILES as SAVE_FASTQ_OUTPUT       } from '../../modules/stenglein-lab/save_output_files/main'

workflow CLASSIFY_READS {

 take:
  input_fastq_dir        // the path to a directory containing fastq file(s) or a comma-separated list of dirs
  fastq_pattern          // the regex that will be matched to identify fastq

 main:

  // define some empty channels for keeping track of stuff
  ch_versions         = Channel.empty()                                               
  ch_fastq_counts     = Channel.empty()                                               
  ch_processed_fastq  = Channel.empty()                                               
  ch_multiqc_files    = Channel.empty()

  if (params.reads_already_preprocessed) {

    // if the reads have already been pre-processed (trimmed for adapters, quality, etc)

    MARSHAL_FASTQ(input_fastq_dir, fastq_pattern)
    ch_processed_fastq  = MARSHAL_FASTQ.out.reads
    ch_versions         = ch_versions.mix(MARSHAL_FASTQ.out.versions)
    ch_fastq_counts     = ch_fastq_counts.mix(MARSHAL_FASTQ.out.fastq_counts)

  } else {

    // do read pre-processing (trim adapters, low quality, etc)

    PREPROCESS_READS(input_fastq_dir, fastq_pattern, params.collapse_duplicate_reads)
    ch_processed_fastq  = PREPROCESS_READS.out.reads
    ch_versions         = ch_versions.mix(PREPROCESS_READS.out.versions)
    ch_fastq_counts     = ch_fastq_counts.mix(PREPROCESS_READS.out.fastq_counts)
    ch_multiqc_files    = PREPROCESS_READS.out.multiqc_files
  }

  // COLLECT_READS(ch_process_fastq.collect)

  KRAKEN2_WORKFLOW(ch_processed_fastq)

  PROCESS_KRAKEN_OUTPUT(KRAKEN2_WORKFLOW.out.kraken2_report.collectFile(name: "collected_kraken_output.txt"))

  // SAVE_FASTQ_OUTPUT(ch_processed_reads.map{meta, reads -> reads})

  ch_versions    = ch_versions.mix(KRAKEN2_WORKFLOW.out.versions)


 emit: 
  versions        = ch_versions
  multiqc_files   = ch_multiqc_files 
  fastq_counts    = ch_fastq_counts 
  processed_fastq = ch_processed_fastq

}
