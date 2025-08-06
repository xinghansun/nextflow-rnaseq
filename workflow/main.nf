#! /usr/bin/env nextflow

// import modules
include { fastp_short } from '../modules/fastp/fastpshort/main.nf'
include { hisat2_build } from '../modules/hisat2/build/main.nf'
include { hisat2_align } from '../modules/hisat2/align/main.nf'

params.sample_csv = '../data/paired-end.csv'
// params.sample_csv = '../data/single-end.csv'
params.data_dir = '../data/reads'
params.hisat2_index = null
params.genome_fasta = '../data/genome.fa'


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

	// hisat2 alignment
	Channel.fromPath(params.genome_fasta)
		.set {ch_genomefa}

	// use first to convert it into a value channel to make it reusable
	if (params.hisat2_index) {
		Channel
			.fromPath("${params.hisat2_index}/*.ht2", checkIfExists: true)
			.collect()
			.first()
			.set { ch_index }
	} else {
		hisat2_build(ch_genomefa)
		hisat2_build.out.index
			.first()
			.set { ch_index }
	}

	hisat2_align(fastp_short.out.trimmed_reads, ch_index)

}