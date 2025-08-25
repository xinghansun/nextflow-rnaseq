#! /usr/bin/env nextflow

// import modules
include { fastp_short } from '../modules/fastp/fastpshort/main.nf'

// import subworkflows
include { hisat2_align_wf } from '../subworkflows/hisat2_align_wf/main.nf'
include { stringtie_count_wf } from '../subworkflows/stringtie_count_wf/main.nf'
include { salmon_pseudocount_wf } from '../subworkflows/salmon_pseudocount_wf/main.nf'

params.sample_csv = '../data/paired-end.csv'
// params.sample_csv = '../data/single-end.csv'
params.data_dir = '../data/reads'
params.hisat2_index = null
params.genome_fasta = '../data/genome.fa'
params.aligner = 'salmon' // or hisat2


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

	// load ref genome fasta
	Channel.fromPath(params.genome_fasta)
		.set {ch_genomefa}

	// fastp trim for short read
	fastp_short(ch_fastq)

	// hisat2 alignment
	hisat2_align_wf(fastp_short.out.trimmed_reads, ch_genomefa, params.hisat2_index)
	stringtie_count_wf(hisat2_align_wf.out.bam, hisat2_align_wf.out.bai)

	// salmon
	salmon_pseudocount_wf(fastp_short.out.trimmed_reads, ch_genomefa)

}