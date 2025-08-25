#! /usr/bin/env nextflow

include { wget_ensemblegtf } from '../../modules/wget/ensemblegtf/main.nf'
include { stringtie_count } from '../../modules/stringtie/count/main.nf'

workflow stringtie_count_wf {
	take:
	bam // channel: [ val(sample_id), bam ]
    bai // channel: [ val(sample_id), bai ]
    
	main:
    wget_ensemblegtf()
	stringtie_count(bam, bai, wget_ensemblegtf.out.ref_gtf)

	emit:
	gtf = stringtie_count.out.gtf // channel: [ val(sample_id), gtf ]
	abundance = stringtie_count.out.abundance // channel: [ val(sample_id), abundance ]
}