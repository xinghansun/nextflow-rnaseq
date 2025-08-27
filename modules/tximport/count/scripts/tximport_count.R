library(optparse)

suppressPackageStartupMessages({
  library(tximport)
  library(readr)
  library(rtracklayer)
})

# parse args
option_list <- list(
    make_option(
        c("-g", "--gtf"),
        type="character",
        action="store",
        help="GTF file",
        dest="gtf_file"
    ),
    make_option(
        c("-i", "--input"), 
        type="character", 
        action="store", 
        help="Input quant.sf files", 
        dest="input_files"),
    make_option(
        c("-I", "--id"),
        type="character",
        action="store",
        help="Sample IDs",
        dest="sample_ids"),
    make_option(
        c("-o", "--output"), 
        type="character", 
        action="store", 
        help="Output file", 
        dest="output_file")
)
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)


if (length(opt$output_file) != 1) {
    print(opt$output_file)
    stop("Error: Only one output file (-o / --output) must be provided.")
}

gtf <- import(opt$gtf_file, format="gtf")
quant_files <- strsplit(opt$input_files, ",")[[1]] # R package not stable for multi args
sample_ids <- strsplit(opt$sample_ids, ",")[[1]]
out_file <- opt$output_file

# load tx2gene
tx2gene <- data.frame(
    transcript_id = mcols(gtf)$transcript_id,
    gene_id = mcols(gtf)$gene_id
)

# Keep only unique pairs
tx2gene <- unique(tx2gene)

# Import
files <- setNames(quant_files, sample_ids)
message(sprintf("Importing files: %s", paste(files, collapse=", ")))

txi <- tximport(
    files, 
    type="salmon", 
    txOut=TRUE, 
    dropInfReps=TRUE)

# Strip version numbers from transcript IDs to match tx2gene
rownames(txi$counts) <- sub("\\..*", "", rownames(txi$counts))
rownames(txi$abundance) <- sub("\\..*", "", rownames(txi$abundance))
rownames(txi$length) <- sub("\\..*", "", rownames(txi$length))

txi_gene <- summarizeToGene(
    txi, 
    tx2gene, 
    countsFromAbundance="lengthScaledTPM")

write.table(
    txi_gene$counts, 
    file=out_file, 
    sep="\t", quote=FALSE, col.names=NA)
