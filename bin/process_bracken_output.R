#!/usr/bin/env Rscript 

library (tidyverse)

# This script reads in a table of fastq counts and generates some plots and summaries
#
# Mark Stenglein Nov 9, 2023 

# ------------------------
# import fastq / bam read count info.   
# ------------------------
if (!interactive()) {
  # if running from Rscript
  args = commandArgs(trailingOnly=TRUE)
  bracken_output_file = args[1]
  output_directory="./"
} else {
  # if running via RStudio
  # count_file_names = list.files(path = "../results/fastq_counts", pattern = "*count.txt$", full.names = T)
  # output_directory="../results/"
}

df <- read.delim(bracken_output_file, sep="\t", header=F)


