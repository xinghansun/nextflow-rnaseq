#! /usr/bin/env nextflow

include { hisat2_build } from '../../modules/hisat2/build/main.nf'
include { hisat2_align } from '../../modules/hisat2/align/main.nf'

workflow hisat2_align_wf {
	take:
	ch_reads // channel: [ val(sample_id), [ reads ]]
	ch_genomefa // channel: /path/to/genome.fa
	hisat2_index // val: /path/to/index
	
	main:
	// use first to convert it into a value channel to make it reusable
	if (hisat2_index) {
		Channel
			.fromPath("${hisat2_index}/*.ht2", checkIfExists: true)
			.collect()
			.first()
			.set { ch_index }
	} else {
		hisat2_build(ch_genomefa)
		hisat2_build.out.index
			.first()
			.set { ch_index }
	}

	hisat2_align(ch_reads, ch_index)

	emit:
	bam = hisat2_align.out.bam // channel: [ val(sample_id), bam ]
	bai = hisat2_align.out.bai // channel: [ val(sample_id), bai ]
	summary = hisat2_align.out.summary // channel: [val(sample_id), summary ]
}