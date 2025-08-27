#! /usr/bin/env nextflow

include { wget_v48transcript } from '../../modules/wget/gencodev48transcript/main.nf'
include { salmon_index } from '../../modules/salmon/index/main.nf'
include { salmon_quant } from '../../modules/salmon/quant/main.nf'
include { tximport_count } from '../../modules/tximport/count/main.nf'

workflow salmon_pseudocount_wf {
	take:
	ch_reads // channel: [ val(sample_id), [ reads ]]
	ch_genomefa // channel: /path/to/genome.fa
	ensemble_gtf // channel: /path/to/Homo_sapiens.GRCh38.114.gtf

	main:
	wget_v48transcript()
	salmon_index(wget_v48transcript.out.gencode_trans, ch_genomefa)
	salmon_index.out.index
		.first()
		.set { ch_index}
	salmon_quant(ch_reads, ch_index)

	salmon_quant.out.quant
		.collect { it[0] }
		.set { ch_salmon_samples }

	salmon_quant.out.quant
		.collect { it[1] }
		.set { ch_salmon_quants }

	tximport_count(ch_salmon_samples, ch_salmon_quants, ensemble_gtf)

	emit:
	quant = salmon_quant.out.quant // channel: [ val(sample_id), path(quant.sf) ]
	gene_counts = tximport_count.out.merged_counts // channel: /path/to/merged_gene_counts.tximport.tsv
}