get_pheno_data <- function(data.df=NULL, combined_variables_to_id="Library", plate_variables=NULL) {
  phenodata <- data.frame(row.names=colnames(data.df))
  phenodata$names <- row.names(phenodata)
  phenodata <- separate(phenodata, col = "names", into = plate_variables, sep = "_")
  ncol_meta <- ncol(phenodata)
  ## Replace by tinyverse using the columns mentioned with combined_variables_to_id
  if (length(combined_variables_to_id) > 1) {
    phenodata$combined_id <- apply(phenodata[,combined_variables_to_id], 1, paste, collapse = "_")
  } else {
    phenodata$combined_id <- phenodata[,combined_variables_to_id]
  }
  # Only take the entries that are matchable with the counttable entries:
  pheno_matched <- phenodata[rownames(phenodata) %in% colnames(data.df),]
  # Matching phenodata with the dataset ordering
  pheno_ordered <- pheno_matched[match(colnames(data.df),rownames(pheno_matched)),]
  return(list(pheno_ordered, pheno_matched, ncol_meta))
}

read_pheno_data <- function(path=NULL, data.df=NULL, combined_variables_to_id="Library", lab_col="Library") {
  phenodata <- read.csv(file = path)
  print(colnames(phenodata))
  #Combine genome and sample column
  base_cols <- c("Genome","Sample","Barcode")
  `%notin%` <- Negate(`%in%`)
  if (lab_col %notin% colnames(phenodata)) {
    stop("Library column not found!. Make sure that Library is a column in meta data! ")
  }
  if (base_cols %notin% colnames(phenodata)) {
    stop("Base columns not found. The meta should minimally contain columns: sample,genome,barcode and library")
  }
  rownames(phenodata) <- apply(phenodata[,base_cols],1,paste,collapse = "_")
  ncol_meta <- ncol(phenodata)
  #Add custom id to phenodata
  if (length(combined_variables_to_id) > 1) {
    phenodata$combined_id <- apply(phenodata[,combined_variables_to_id], 1, paste, collapse = "_")
  } else {
    phenodata$combined_id <- phenodata[,combined_variables_to_id]
  }
  ## Replace by tinyverse using the columns mentioned with combined_variables_to_id
  # Only take the entries that are matchable with the counttable entries:
  #phenodata <- t(phenodata)
  pheno_matched <- phenodata[rownames(phenodata) %in% colnames(data.df),]
  # Matching phenodata with the dataset ordering
  pheno_ordered <- pheno_matched[match(colnames(data.df),rownames(pheno_matched)),]
  return(list(pheno_ordered, pheno_matched, ncol_meta))
}

