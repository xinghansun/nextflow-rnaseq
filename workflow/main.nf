#! /usr/bin/env nextflow

// import modules
include { fastp_short } from '../modules/fastp/fastpshort/main.nf'
include { tximport_count } from '../modules/tximport/count/main.nf'
include { wget_ensemblegtf } from '../modules/wget/ensemblegtf/main.nf'

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

	// hisat2 alignment and count
	hisat2_align_wf(fastp_short.out.trimmed_reads, ch_genomefa, params.hisat2_index)
	stringtie_count_wf(hisat2_align_wf.out.bam, hisat2_align_wf.out.bai)

	// salmon pseudoalignment count
	salmon_pseudocount_wf(fastp_short.out.trimmed_reads, ch_genomefa)

	salmon_pseudocount_wf.out.quant
		.collect { it[0] }
		.set { ch_salmon_samples }
	
	salmon_pseudocount_wf.out.quant
		.collect { it[1] }
		.set { ch_salmon_quants }

	wget_ensemblegtf()
	tximport_count(ch_salmon_samples, ch_salmon_quants, wget_ensemblegtf.out.ref_gtf)
}