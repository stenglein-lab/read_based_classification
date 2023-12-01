process CHECK_KRAKEN2_DB {
  tag "$db_dir"
  label 'process_low'

  input:
  path db_dir

  output:
  path db_dir, emit: db_path

  when:
  task.ext.when == null || task.ext.when

  script:
  """
  # this is a simple check: this file should exist if a legit k2 database
  ls ${db_dir}/hash.k2d
  """




}
