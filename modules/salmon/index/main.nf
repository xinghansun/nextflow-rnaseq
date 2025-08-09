#! /usr/bin/env nextflow

process salmon_index {
	publishDir "result/salmon/index"

	conda "${moduleDir}/environment.yml"

	input:
	path gencode_transcript
	path genome_fasta

	output:
	path "salmon_index", emit: index

	script:
	"""
	grep "^>" ${genome_fasta} | cut -d " " -f1 | sed 's/>//g' > decoys
	( gunzip -c gencode.v48.transcripts.fa.gz; cat genome.fa ) > combined_tmp.fa
	salmon index -t combined_tmp.fa -d decoys -i salmon_index --gencode
	"""

}