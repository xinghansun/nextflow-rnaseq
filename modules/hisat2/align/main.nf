#! /usr/bin/env nextflow

process hisat2_align {
	tag "${sample_id}"
	publishDir "result/hisat2/aligned"

	conda "${moduleDir}/environment.yml"

	input:
	tuple val(sample_id), path(reads)
	path(index)

	output:
	tuple val(sample_id), path("${sample_id}.hisat2.bam"), emit: bam
	tuple val(sample_id), path("${sample_id}.hisat2.summary"), emit: summary

	script:
	def reads_syntax = reads.size() == 2 ? "-1 ${reads[0]} -2 ${reads[1]}" : "-U ${reads}"
	def index_prefix = "${index[0]}".replaceAll(/\.\d\.ht2$/, '') 
	"""
	hisat2 \\
		-x ${index_prefix} \\
		${reads_syntax} \\
		-S ${sample_id}.hisat2.sam \\
		-p ${task.cpus} \\
		--summary-file ${sample_id}.hisat2.summary
	samtools view -b -F 260 ${sample_id}.hisat2.sam > ${sample_id}.hisat2.bam
	"""
}