#! /usr/bin/env nextflow

process salmon_quant {
	tag "${sample_id}"
	publishDir "result/salmon/quant"

	conda "${moduleDir}/environment.yml"

	input:
	tuple val(sample_id), path(reads)
	path salmon_index

	output:
	tuple val(sample_id), path("${sample_id}/quant.sf"), emit: quant
	path("${sample_id}/cmd_info.json"), emit: cmd_info
	path("${sample_id}/lib_format_counts.json"), emit: lib_format_counts
	path("${sample_id}/logs/"), optional: true, emit: logs
	path("${sample_id}/aux_info/"), optional: true, emit: aux_info

	script:
	def reads_syntax = (
		reads.size() == 2 
			? "-1 ${reads[0]} -2 ${reads[1]}" 
			: "-r ${reads} --fldMean 250 --fldSD 25")

	"""
	salmon quant \
		-i ${salmon_index} \
		-l A \
		${reads_syntax} \
		-p ${task.cpus} \
		-o ${sample_id}
	"""
}