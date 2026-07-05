#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
sample = args[1]
db = args[2]
tissue = args[3]
dir=args[4]
index=args[5]

# Check if the user asked for help
if ("--help" %in% args || "-h" %in% args || length(args) == 0) {
  cat("Description: post-kbpython cleanup. 1) Merge the quantifications of fragmented/duplicated genes. 2) Change gene IDs to TOGA gene symbols.\n")
  cat("The output cleaned files can be used in inter-species comparisons: TPM for visualization, counts for DESeq2.")
  cat("\n")
  
  cat("Usage: \nRscript post_kbpython.R $sample $db $tissue $dir $index \n")
  cat("\n")
  
  quit(status = 0)
}

  dir=paste0(dir, "/quant_unfiltered/abundance_1/")
  isoform = read.csv(paste0(index, "/kb/t2g_TOGA2.tsv"), sep="\t")
  print(paste0("use gene symbols in ", index, "/kb/t2g_TOGA2.tsv"))
  
  # Read kb_python output gene-level quantifications 
  abundance <- read.csv(paste0(dir, "abundance.gene.tsv"), sep="\t")  

  # remove GENE_NOT_FOUND and _FRAGEMNT 
  abundance = abundance[abundance$gene_id != "GENE_NOT_FOUND",]
  abundance$gene_id = gsub("_FRAGMENT.*", "", abundance$gene_id)
  
  if (!all(abundance$gene_id %in% isoform$gene_id)) {
    print(paste0(sample, ": not all gene IDs are in t2g_TOGA2.tsv"))
    stop()
  }
  
  abundance = merge(abundance, isoform, by="gene_id", all.x = T)
  # get gene IDs and filter out huge gene families
  abundance$gene_name = abundance$transcript
 
  ## sum up counts and tpm of all genes whose IDs mapped to the same gene symbol (fragmented, one2many, many2many)
  # many2one is already one unique quantification
  merged = abundance[!duplicated(abundance$gene_name),]
  for(g in unique(abundance$gene_name[duplicated(abundance$gene_name)])){
    merged[merged$gene_name == g, "est_counts"] = sum(abundance[abundance$gene_name == g, "est_counts"])
    merged[merged$gene_name == g, "tpm"] = sum(abundance[abundance$gene_name == g, "tpm"])
  }
  
  # split into counts and tpm and write out
  print(paste0("write out to ", dir))
  write.table(merged[, c("gene_name", "est_counts")], paste0(dir, "postkb_counts.tsv"), sep="\t", row.names = F, quote=F)
  write.table(merged[, c("gene_name", "tpm")], paste0(dir, "postkb_tpm.tsv"), sep="\t", row.names = F, quote=F)

