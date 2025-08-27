#! /usr/bin/env nextflow

include { stringtie_count } from '../../modules/stringtie/count/main.nf'

workflow stringtie_count_wf {
	take:
	bam // channel: [ val(sample_id), bam ]
    bai // channel: [ val(sample_id), bai ]
	ensemble_gtf // channel: /path/to/Homo_sapiens.GRCh38.114.gtf

	main:
	stringtie_count(bam, bai, ensemble_gtf)

	emit:
	gtf = stringtie_count.out.gtf // channel: [ val(sample_id), gtf ]
	abundance = stringtie_count.out.abundance // channel: [ val(sample_id), abundance ]
}