#! /usr/bin/env nextflow

process wget_ensemblegtf {
	publishDir "result/ref"

	output:
	path "Homo_sapiens.GRCh38.114.gtf", emit: ref_gtf

	script:
	"""
	wget https://ftp.ensembl.org/pub/current_gtf/homo_sapiens/Homo_sapiens.GRCh38.114.gtf.gz
	gunzip Homo_sapiens.GRCh38.114.gtf.gz
	"""
}