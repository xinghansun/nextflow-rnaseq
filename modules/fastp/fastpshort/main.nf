#! /usr/bin/env nextflow

process fastp_short {
	tag "${sample_id}"
	publishDir "result/fastp/${sample_id}"

	conda "${moduleDir}/environment.yml"

	input: 
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("*.fastp.fastq.gz"), emit: trimmed_reads
	tuple val(sample_id), path("${sample_id}.html"), emit: html
	tuple val(sample_id), path("${sample_id}.json"), emit: json

	script:
	def o = reads.size() == 2 ? "${sample_id}_R1.fastp.fastq.gz" : "${sample_id}.fastp.fastq.gz"
	def paired_syntax = reads.size() == 2 ? "-I ${reads[1]} -O ${sample_id}_R2.fastp.fastq.gz" : ""

	"""
	echo "${moduleDir}/environment.yml"
	fastp \\
		-i ${reads[0]} \\
		-o ${o} \\
		-h ${sample_id}.html \\
		-j ${sample_id}.json \\
		${paired_syntax} \\
		--thread ${task.cpus}
	"""

}