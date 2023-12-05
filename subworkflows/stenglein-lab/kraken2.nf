include { CHECK_KRAKEN2_DB           } from '../../modules/stenglein-lab/check_kraken2_db'
include { KRAKEN2_KRAKEN2            } from '../../modules/nf-core/kraken2/kraken2/main'
include { BRACKEN_BRACKEN            } from '../../modules/nf-core/bracken/bracken/main'

include { KRAKENTOOLS_KREPORT2KRONA } from '../../modules/nf-core/krakentools/kreport2krona/main'
include { KRONA_CLEANUP             } from '../../modules/nf-core/krona/krona_cleanup/krona_cleanup'
include { KRONA_KTIMPORTTEXT        } from '../../modules/nf-core/krona/ktimporttext/main'
include { KRONA_KTIMPORTTAXONOMY    } from '../../modules/nf-core/krona/ktimporttaxonomy/main'

include { PREPEND_TSV_WITH_ID as PREPEND_KRAKEN_OUTPUT  } from '../../modules/stenglein-lab/prepend_tsv_with_id/main'
include { PREPEND_TSV_WITH_ID as PREPEND_BRACKEN_OUTPUT } from '../../modules/stenglein-lab/prepend_tsv_with_id/main'

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

  ch_krona_text = Channel.empty()
  ch_krona_html = Channel.empty()

  //  Convert Kraken2 formatted reports into Krona text files
  KRAKENTOOLS_KREPORT2KRONA ( KRAKEN2_KRAKEN2.out.report )
  ch_krona_text = ch_krona_text.mix( KRAKENTOOLS_KREPORT2KRONA.out.txt )
  ch_versions = ch_versions.mix( KRAKENTOOLS_KREPORT2KRONA.out.versions.first() )

  /*
      Remove taxonomy level annotations from the Krona text files
  */
  KRONA_CLEANUP( ch_krona_text )
  ch_cleaned_krona_text = KRONA_CLEANUP.out.txt
  ch_versions = ch_versions.mix( KRONA_CLEANUP.out.versions.first() )

  /*
      Convert Krona text files into html Krona visualizations
  */
  KRONA_KTIMPORTTEXT( ch_cleaned_krona_text )
  ch_krona_html = ch_krona_html.mix( KRONA_KTIMPORTTEXT.out.html )
  ch_versions = ch_versions.mix( KRONA_KTIMPORTTEXT.out.versions.first() )

  // prepend sample ID into KRAKEN output for tidyverse handling downstream
  PREPEND_KRAKEN_OUTPUT(KRAKEN2_KRAKEN2.out.report)
  ch_kraken2_report              = PREPEND_KRAKEN_OUTPUT.out.tsv_file

  // other KRAKEN2 output
  ch_classified_reads_assignment = KRAKEN2_KRAKEN2.out.classified_reads_assignment
  ch_unclassified_fastq          = KRAKEN2_KRAKEN2.out.unclassified_reads_fastq
  ch_versions                    = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions)

  // Run bracken
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

  krona_text                  = ch_cleaned_krona_text
  krona_html                  = ch_krona_html

}
