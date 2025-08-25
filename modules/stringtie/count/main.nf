#! /usr/bin/env nextflow

process stringtie_count {
	tag "${sample_id}"
	publishDir "result/stringtie/count"

	conda "${moduleDir}/environment.yml"

	input:
	tuple val(sample_id), path(bam)
    tuple val(sample_id), path(bai)
    path ref_gtf

	output:
	tuple val(sample_id), path("${sample_id}/${sample_id}.stringtie.gtf"), emit: gtf
	tuple val(sample_id), path("${sample_id}/${sample_id}.abundance.tsv"), emit: abundance

	script:
	"""
	stringtie ${bam} \
        -G ${ref_gtf} \
        -p ${task.cpus} \
        -o ${sample_id}/${sample_id}.stringtie.gtf \
        -A ${sample_id}/${sample_id}.abundance.tsv \
        -e -B
	"""
}