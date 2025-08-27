#! /usr/bin/env nextflow

process tximport_count {
    publishDir "result/salmon/quant"

    conda "${moduleDir}/environment.yml"

    input:
    val sample_ids
    path quant_files, stageAs: "?/*"
    path ensemble_gtf

    output:
    path "merged_gene_counts.tximport.tsv", emit: merged_counts

    script:
    """
    Rscript ${moduleDir}/scripts/tximport_count.R \\
        -i ${quant_files.join(",")} \\
        -I ${sample_ids.join(",")} \\
        -g ${ensemble_gtf} \\
        -o merged_gene_counts.tximport.tsv
    """
}