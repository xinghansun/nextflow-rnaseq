#! /usr/bin/env nextflow

// import modules
include { fastp_short } from '../modules/fastp/fastpshort/main.nf'

// params.sample_csv = '../data/paired-end.csv'
params.sample_csv = '../data/single-end.csv'
params.data_dir = '../data/reads'

workflow {
	// parse sample_csv to creat channels
	Channel.fromPath(params.sample_csv)
		.splitCsv(header: true)
		.map { row ->
			def vals = row.values().toList()
			def sample_id = vals[0]
			def files = vals[1..-1].findAll()
					.collect { file("${params.data_dir}/${it}") }
			tuple(sample_id, files)
		}
		.set { ch_fastq }

	// fastp trim for short read
	fastp_short(ch_fastq)
}