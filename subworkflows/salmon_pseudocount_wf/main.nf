#! /usr/bin/env nextflow

include { wget_v48transcript } from '../../modules/wget/gencodev48transcript/main.nf'
include { salmon_index } from '../../modules/salmon/index/main.nf'
include { salmon_quant } from '../../modules/salmon/quant/main.nf'

workflow salmon_pseudocount_wf {
	take:
	ch_reads // channel: [ val(sample_id), [ reads ]]
	ch_genomefa // channel: /path/to/genome.fa

	main:
	wget_v48transcript()
	salmon_index(wget_v48transcript.out.gencode_trans, ch_genomefa)
	salmon_index.out.index
		.first()
		.set { ch_index}
	salmon_quant(ch_reads, ch_index)

	emit:
	quant = salmon_quant.out.quant // channel: [ val(sample_id), path(quant.sf) ]
}