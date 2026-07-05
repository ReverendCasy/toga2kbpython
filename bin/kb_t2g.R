#!/usr/bin/env Rscript

args <- commandArgs(TRUE)
db = args[1]
dir = args[2]

# Check if the user asked for help
if ("--help" %in% args || "-h" %in% args || length(args) == 0) {
  cat("Description: for a reference assembly used in kb_python, generate the file that matches each gene ID with the TOGA-output gene symbols based on the kb_python index t2g.txt, with gene symbols merged for fragmented and/or duplciated genes")
  cat("\n")
  
  cat("Usage: \nRscript kb_t2g_TOGA2.R $db [$dir]\n")
  cat("db is the assembly name (e.g. HLlepYer2A)\n")
  cat("dir is the kb index dir (needs to include '/' at the end), this is also the output dir")
  cat("\n")
  
  quit(status = 0)
}

if(file.exists(paste0(dir, "t2g_TOGA2.tsv"))){
  print(paste0("the isoform file for ", db, " has been generated"))
} else {
  print(paste0("preparing the t2g_TOGA2 file for ", db)) 
  
  ## get the kb_python index file for this species
  isoform = read.table(paste0(dir, "t2g.txt"), comment.char = "")
  isoform = isoform[,1:2]
  names(isoform) = c("transcript", "gene_id")
  ## remove GENE_NOT_FOUND
  isoform = isoform[isoform$gene_id != "GENE_NOT_FOUND",]
  ## remove FRAGMENT gene names: would separate them from the other duplicates if this gene is *many*
  isoform$gene_id = gsub("_FRAGMENT.*", "", isoform$gene_id)
  ## replace transcript names by TOGA gene symbols
  isoform$transcript = as.character(sapply(isoform$transcript, FUN=function(x){
    unlist(strsplit(x, split="#"))[2]
  }))
  ## remove duplicates (now this is the gene list)
  isoform = unique(isoform)
  ## remove unprintable strings
  # isoform$gene_id <- gsub("[^[:print:]]", "", isoform$gene_id)
  
  ## merge gene symbols
  ## 1. many2one: different gene symbols mapped to the same query gene
  isoform2 = isoform[!duplicated(isoform$gene_id),]
  for(g in unique(isoform$gene_id[duplicated(isoform$gene_id)])){
    isoform2[isoform2$gene_id == g, "transcript"] = paste0(sort(unlist(isoform[isoform$gene_id == g, "transcript"])), collapse=",")
  }
  isoform = isoform2
  rm(isoform2)
  
  ## 2. many2many: merge gene names that overlap
  for(t in unique(grep(",", isoform$transcript, value=T))){
    for(tx in unlist(strsplit(t, split=","))){
      genes = unique(c(grep(paste0("^", tx, "$"), isoform$transcript), 
                       grep(paste0("^", tx, ","), isoform$transcript),
                       grep(paste0(",", tx, ","), isoform$transcript),
                       grep(paste0(",", tx, "$"), isoform$transcript)))
      if(length(genes) > 1){
        all = isoform$transcript[genes]
        new_name = paste0(sort(unique(unlist(strsplit(all, split=",")))), collapse=",")
        isoform[genes, "transcript"] = new_name
      } 
    }
  }
  ## record the "many" in the hg38 reference
  isoform$TOGA_ref = sapply(isoform$transcript, FUN=function(x){
    length(unlist(strsplit(x, split=",")))
  }) 
  
  write.table(isoform, paste0(dir, "/t2g_TOGA2.tsv"), sep="\t", quote = F, row.names = F)
}  
