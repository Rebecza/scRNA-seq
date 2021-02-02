# scRNA-seq analysis #

Downstream analysis and exploration, using the QC-ed and preprocessed dataset (`preprocessing/`).

In this script I use Seurat to perform: 
- The final UMAP embedding (explored with the preprocessing script results: Looking at the PCs explaining most variation in the dataset (PCHeatmaps), and some example UMAPs with various settings)
- Clustering with Louvain
- Checking the Cell Cycle phase
- (Optional) Subsetting of the dataset and rerunning the preprocessing (for instance on CC-phase, e.g. only taking G1 cells).
- Saving the dataset for further use in R (RDS object, Seurat object) and Python (H5AD object, usable in Scanpy).

