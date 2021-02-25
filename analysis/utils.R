### Extracts kb-python counts from source directory
read_kb_counts <- function(dir, name, barcode_file, remove_bc=TRUE, replace_col_old="", replace_col_with="") {
  # Loading scRNA-seq count matrix
  #
  # Generates a combined scRNA-seq matrix from the ouput of 
  # the Kallisto | Bustools wrapper. Needs the location of
  # the count tables to combine. Returned matrix consists of 
  # genes (with gene names) in the rows, and cells (with 
  # barcode identifier) in the columns. 
  #
  # dir: location of the "_output" folders generated 
  #   by the kb-wrapper
  # name: the name of count assay you want to load (e.g. 
  #   spliced, unspliced or cells_x_genes, the latter when 
  #   running without velocity)
  
  # barcode_file is a 2-column file with a well-id its respective DNA barcode
  # t2g_file is the transcript-to-gene file created with the kb-wrapper genome index
  
  # Change only the parameters in this block:
  #----------------------------#
  #----------------------------#
  
  ## Loading packages & files ##
  library(Matrix)
  library(tidyr)
  library(dplyr)
  
  ## Generate matrix ##
  
  # Iterate over all _output folders, generating matrix per plate
  # combining matrices by gene matches
  dir <- normalizePath(dir, mustWork = TRUE)
  output_folders <- list.files(dir, 
                               recursive = FALSE, include.dirs = TRUE)
  
  for (i in 1: length(output_folders)){
    folder <- output_folders[[i]]
    print(paste("Reading:",folder))
    plate <- paste0(dir, "/", folder, "/counts_unfiltered/", name)
    m <- readMM(paste0(plate, ".mtx"))
    m <- Matrix::t(m)
    m <- as(m, "dgCMatrix")
    # the matrix has genes in columns, cells in rows, 
    # stored in .genes.txt and .barcodes.txt
    genes <- as.vector(read.table(file(paste0(plate, ".genes.txt")))[,1])
    barcodes <- as.vector(read.table(file(paste0(plate, ".barcodes.txt")))[,1])
    # retrieve unique plate-id from folder
    #platename <- gsub("GRCh38-", "", folder)
    colnames(m) <- paste(barcodes, folder, sep = "_")
    rownames(m) <- genes
    # create a combined matrix for all plates in the folder
    if (i == 1) {
      combined <- m
    } else if (identical(rownames(combined),rownames(m)) == TRUE){
      # Only binds the matrices if genes are identical and in the same order
      combined <- cbind(combined, m)
    }
  }
  cells <- data.frame("cell" = colnames(combined))
  cells$barcode <- gsub("_.*", "", cells$cell)
  if (remove_bc){
    barcode_file <- barcode_file
    ## Replace cell barcodes for well identifier ##
    # barcode file contains the well identifier and corresponding DNA barcode
    plate_order <- read.table(barcode_file, sep = "\t", col.names = c("well","barcode"))
    # generate a data.frame to match barcode and wellid 
    cells$well <- plate_order$well[match(cells$barcode, plate_order$barcode)]
    # Remove DNA barcode and add wellid 
    cells$cell_id <- paste(gsub("^.*?_", "", cells$cell), cells$well, sep = "_")
    cells$cell_id <- gsub("-", "_", cells$cell_id)
    # replace cell names of the count matrix
    colnames(combined) <- cells$cell_id
  } else {
    # Remove DNA barcode and add wellid 
    cells$cell_id <- paste(gsub("^.*?_", "", cells$cell), cells$barcode, sep = "_")
    cells$cell_id <- gsub("-", "_", cells$cell_id)
    # replace cell names of the count matrix
    colnames(combined) <- cells$cell_id
  }
  if (replace_col_old != "") {
    colnames(combined) <- gsub(replace_col_old, replace_col_with, colnames(combined))
  }
  return(combined)
}

##Extracts meta data from sample names
extract_meta_data <- function(cell.names=NULL, group_id="Library", meta_cols=NULL) {
  phenodata <- data.frame(row.names=cell.names)
  phenodata$names <- row.names(phenodata)
  phenodata <- separate(phenodata, col = "names", into = meta_cols, sep = "_")
  ncol_meta <- ncol(phenodata)
  ## Replace by tinyverse using the columns mentioned with group_id
  if (length(group_id) > 1) {
    phenodata$combined_id <- apply(phenodata[,group_id], 1, paste, collapse = "_")
  } else {
    phenodata$combined_id <- phenodata[,group_id]
  }
  # Only take the entries that are matchable with the counttable entries:
  pheno_matched <- phenodata[rownames(phenodata) %in% cell.names,]
  # Matching phenodata with the dataset ordering
  pheno_ordered <- pheno_matched[match(cell.names,rownames(pheno_matched)),]
  return(list(pheno_ordered, pheno_matched, ncol_meta))
}

#Reads meta data from 
read_meta_data <- function(path=NULL, cell.names=NULL, group_id="Library", lab_col="Library") {
  phenodata <- read.csv(file = path)
  #Combine genome and sample column
  base_cols <- c("Genome","Sample","Barcode")
  `%notin%` <- Negate(`%in%`)
  if (c(base_cols,lab_col) %notin% colnames(phenodata)) {
    stop("Base columns not found. The meta should minimally contain columns: Sample,Genome,Barcode and Library")
  }
  rownames(phenodata) <- apply(phenodata[,base_cols],1,paste,collapse = "_")
  ncol_meta <- ncol(phenodata)
  #Add custom id to phenodata
  if (length(group_id) > 1) {
    phenodata$combined_id <- apply(phenodata[,group_id], 1, paste, collapse = "_")
  } else {
    phenodata$combined_id <- phenodata[,group_id]
  }
  ## Replace by tinyverse using the columns mentioned with group_id
  # Only take the entries that are matchable with the counttable entries:
  #phenodata <- t(phenodata)
  pheno_matched <- phenodata[rownames(phenodata) %in% cell.names,]
  # Matching phenodata with the dataset ordering
  pheno_ordered <- pheno_matched[match(cell.names,rownames(pheno_matched)),]
  return(list(pheno_ordered, pheno_matched, ncol_meta))
}

####### Plotting functions for plate QC ######
QC_ERCC_384plot <- function(file, name){
  library(RColorBrewer)
  library(plot3D)
  low <- "#313695";mid="#FFFFBF"; high="#A50026"   ## three-class RdYlBu, 11 levels
  RdYlBu.orig <- colorRampPalette(c(low,mid,high))(91)
  palette <- colorRampPalette(rev(brewer.pal(n = 11,name = "RdYlBu")))(10) # pick which palette for plate plotting
  
  coordinates<-expand.grid(seq(1,24),rev(seq(1,16)))
  #plot(expand.grid(x = c(1:24), y=c(1:16)),main=name,ylab=NA,xlab=NA, xlim=c(1,24), cex=1.5, xaxt="n", yaxt="n") #plate layout
  plot(expand.grid(x = c(1:24), y=c(1:16)),ylab=NA,xlab=NA, xlim=c(1,24), cex=1.5, xaxt="n", yaxt="n") #plate layout
  title(name, line = 2.5)
  axis(2, at=c(1:16),labels =rev(LETTERS[1:16]), las=2)
  axis(3, at=c(1:24), labels = c(1:24))
  points(coordinates,pch=19,col=palette[cut(log10(colSums(file)),include.lowest = T,
                                            breaks=unique(c(0,0.2,0.4,0.6,0.8,1,1.2,1.4,1.6,1.8,max(colSums(file)))))], cex=1.4)
  colkey(col=RdYlBu.orig, side=1, add=T, clab="number of ERCC-reads in log10",
         line.clab = 1.25, length=0.8, clim=c(0,2))
}

QC_umis_384plot<-function(file, name){
  library(RColorBrewer)
  library(plot3D)
  low <- "#313695";mid="#FFFFBF"; high="#A50026"   ## three-class RdYlBu, 11 levels
  RdYlBu.orig <- colorRampPalette(c(low,mid,high))(91)
  palette <- colorRampPalette(rev(brewer.pal(n = 11,name = "RdYlBu")))(10) # pick which palette for plate plotting
  
  coordinates<-expand.grid(seq(1,24),rev(seq(1,16)))
  UMIsFig <- plot(expand.grid(x = c(1:24), y=c(1:16)),ylab=NA,xlab=NA, xlim=c(1,24), cex=1.5, xaxt="n", yaxt="n") #plate layout
  title(name, line = 2.5)
  axis(2, at=c(1:16),labels =rev(LETTERS[1:16]), las=2)
  axis(3, at=c(1:24), labels = c(1:24))
  print(paste0("Maximum column sum of plate ",name, " :" , max(colSums(file))))
  points(coordinates,pch=19,col=palette[cut(log10(colSums(file)),
                                            breaks=unique(c(0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,max(colSums(file)))))], cex=1.4) # plot total non-ERCC reads/cell over layout
  # cut is used here to  separate and fall the values into different internals (10 is set to tell R 10 internals are set.)
  colkey(col=RdYlBu.orig, side=1, add=T, clab="number of unique counts in log10",
         line.clab = 1.25, length=0.8, clim=c(0,5))
  
}

plate_qc <- function(data.df = NULL, spliced.data.df=NULL, barcode_file = NULL, out.file= NULL ) {
  plate_order <- read.table(barcode_file, sep = "\t", col.names = c("well","barcode"))
  #
  # # Make a vector with all plate numbers
  platenrs <- unique(gsub("([^_]*)$", "", colnames(data.df)))
  pdf(out.file, paper = "USr")
  # # settings for the plate diagnostics pdf
  par(mfrow=c(2,2), mar = c(5,4,4,2) + 0.1, cex.main = 1)
  #
  # # Iterate over all plates, order cells in the order of visualization
  for (plate in platenrs){
    #   # use the order of cells from te barcode file (this is A1, A2, A3, etc to P24)
    primer_order <- paste(plate, plate_order$well, sep="")
    #
    #   # if wells are missing on the plate, these need to be added and given a value of 0
    missing_wells <- primer_order[!primer_order %in% colnames(spliced.data.df)]
    cols_to_add <- data.frame(matrix(ncol = length(missing_wells), nrow = length(rownames(spliced.data.df))))
    colnames(cols_to_add) <- missing_wells
    cols_to_add[is.na(cols_to_add)] <- 0
    diag_plate <- cbind(spliced.data.df[,grep(plate, colnames(spliced.data.df))], cols_to_add)
    #   # phenodata contains same cellid entry + rowname as used in dataset
    cells_order <- colnames(diag_plate[,match(primer_order, colnames(diag_plate))])
    #
    #   # match dataset cells order with wells in the visualization
    tmp <- as.matrix(diag_plate[,cells_order])
    QC_umis_384plot(tmp, paste(plate, "UMI_QC", sep = "_"))
    QC_ERCC_384plot(tmp[grep("^ERCC", rownames(diag_plate)),], paste(plate, "ERCC_QC", sep = "_"))
    #
    rm(tmp)
  }
}
