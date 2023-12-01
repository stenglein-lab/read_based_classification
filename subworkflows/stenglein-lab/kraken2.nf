include { CHECK_KRAKEN2_DB           } from '../../modules/stenglein-lab/check_kraken2_db'
include { KRAKEN2_KRAKEN2            } from '../../modules/nf-core/kraken2/kraken2/main'
include { BRACKEN_BRACKEN            } from '../../modules/nf-core/bracken/bracken/main'

workflow KRAKEN2_WORKFLOW {

 take:
  reads           // [meta, [fastq]]

 main:

  // define some empty channels for keeping track of stuff
  ch_versions         = Channel.empty()                                               

  // simple check that kraken2 db exists at specified path.  returns db path.
  CHECK_KRAKEN2_DB(params.kraken2_db_dir)

  // ch_kraken2_report              = Channel.empty()
  // ch_classified_reads_assignment = Channel.empty()
  // ch_unclassified_fastq          = Channel.empty()

  // K2 options
  def save_output_fastqs    = true
  def save_reads_assignment = true

  // Run KRAKEN2
  KRAKEN2_KRAKEN2(reads, CHECK_KRAKEN2_DB.out.db_path, save_output_fastqs, save_reads_assignment)

  ch_kraken2_report              = KRAKEN2_KRAKEN2.out.report
  ch_classified_reads_assignment = KRAKEN2_KRAKEN2.out.classified_reads_assignment
  ch_unclassified_fastq          = KRAKEN2_KRAKEN2.out.unclassified_reads_fastq
  ch_versions                    = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions)

  BRACKEN_BRACKEN(KRAKEN2_KRAKEN2.out.report, CHECK_KRAKEN2_DB.out.db_path)
  ch_bracken_reports          = BRACKEN_BRACKEN.out.reports
  ch_bracken_species          = BRACKEN_BRACKEN.out.txt
  ch_versions                 = ch_versions.mix(BRACKEN_BRACKEN.out.versions)

 emit: 
  versions                    = ch_versions
  kraken2_report              = ch_kraken2_report 
  classified_reads_assignment = ch_classified_reads_assignment
  unclassified_fastq          = ch_unclassified_fastq 

  bracken_reports             = ch_bracken_reports
  bracken_species             = ch_bracken_species

}
