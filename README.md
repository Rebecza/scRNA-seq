# scRNA-seq # 
Preprocessing datasets, starting from mapping the raw data from the plate-based CEL-seq2 protocol (`mapping/`) and generating a processed and QC-ed dataset for downstream applications. 

The dataset will be preprocessed for use of RNA Velocity, therefore also processing the unspliced reads.

- From fastq to preprocessed counttable (for in-house CELSeq2 method), with Kallisto | Bustools workflow.
- QC-ed, normalized and dimensionality reduced in custom R scripts, with Scater and Seurat. 
