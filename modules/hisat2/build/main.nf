#! /usr/bin/env nextflow

process hisat2_build {
	publishDir "result/hisat2/index"

	conda "${moduleDir}/environment.yml"

	input: 
	path genome_fasta

	output:
	path "genome_index.*.ht2", emit: index

	script:
	"""
	hisat2-build \\
		--threads ${task.cpus} \\
		${genome_fasta} \\
		genome_index
	"""
}