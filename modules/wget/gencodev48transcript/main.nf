#! /usr/bin/env nextflow

process wget_v48transcript {
	publishDir "result/ref"
	
	output:
	path 'gencode.v48.transcripts.fa.gz', emit: gencode_trans

	script:
	"""
	wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_48/gencode.v48.transcripts.fa.gz
	"""
}