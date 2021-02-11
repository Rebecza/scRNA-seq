get_pheno_data <- function(data.df=NULL, combined_variables_to_id=NULL, plate_variables=NULL) {
  phenodata <- data.frame(row.names=colnames(data.df))
  phenodata$names <- row.names(phenodata)
  phenodata <- separate(phenodata, col = "names", into = plate_variables, sep = "_")
  
  ## Replace by tinyverse using the columns mentioned with combined_variables_to_id
  phenodata$combined_id <- apply(phenodata[,combined_variables_to_id], 1, paste, collapse = "_")
  
  # Only take the entries that are matchable with the counttable entries:
  pheno_matched <- phenodata[rownames(phenodata) %in% colnames(data.df),]
  
  # Matching phenodata with the dataset ordering
  pheno_ordered <- pheno_matched[match(colnames(data.df),rownames(pheno_matched)),]
  return(list(pheno_ordered, pheno_matched))
}

read_pheno_data <- function(path=NULL, data.df=NULL, combined_variables_to_id=NULL, library_col="Library") {
  phenodata <- read.csv(file = path, row.names = 1)
  `%notin%` <- Negate(`%in%`)
  if (library_col %notin% colnames(phenodata)) {
    stop("Library column not found!. Make sure that Library is a column in meta data! ")
  }
  if (combined_variables_to_id %notin% colnames(phenodata)) {
    stop("cannot combine meta variabel fields to id. Make sure that at least Library is a column in meta data! ")
  }
  ## Replace by tinyverse using the columns mentioned with combined_variables_to_id
  phenodata$combined_id <- apply(phenodata[,combined_variables_to_id], 1, paste, collapse = "_")
  # Only take the entries that are matchable with the counttable entries:
  pheno_matched <- phenodata[rownames(phenodata) %in% colnames(data.df),]
  # Matching phenodata with the dataset ordering
  pheno_ordered <- pheno_matched[match(colnames(data.df),rownames(pheno_matched)),]
  return(list(pheno_ordered, pheno_matched))
}

