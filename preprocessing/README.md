# scRNA-seq: plate-based CEL-Seq2 preprocessing #

Use the `.yaml` file to install the needed environment in Conda (using `mamba` makes this process go much quicker!).

Run in RStudio the R Markdown file with included R-Scripts, for:
- Loading the matrices from the KB-wrapper/Seq2Science pipeline.
- Running plate 'diagnostics' by generating plate overviews for ERCC and UMI counts.
- Filtering the healthy cells and expressed genes, normalize and optionally regress out confounding factors.
- Exploring the counfounding factors in the dataset.
- Running dimensionality reduction and visualizing the variability within the dataset.

Final product is the filtered, normalized and dimensionally reduced dataset that can be used directly for performing clustering, final UMAP visualizations and velocity analysis.
