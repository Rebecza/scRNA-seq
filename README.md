# scRNA-seq preprocessing

From Kallisto | Bustools workflow counttable to preprocessed Seurat object.

![FlowChart_scRNA-seqPreprocessing_sm](https://user-images.githubusercontent.com/56538023/114436621-d804fc00-9bc5-11eb-8dcf-45433f548aa5.png)

# Installation

1. Install [Miniconda](https://docs.conda.io/en/latest/miniconda.html).

2. Install Mamba 
```
conda install mamba -n base -c conda-forge
```

3. Download the newest release or clone this repository.
```
git clone https://github.com/Rebecza/scRNA-seq.git
```

4. Create & activate environment. 
```
cd scRNA-seq/envs
mamba env create -f kb_scrna_R_seurat3.yaml
conda activate kb_scrna_R_seurat3
```

5. Knit the `kb_seurat_pp.rmd` markdown via your method of choice.







## Running the alignment needed for scRNA-seq (and RNA Velocity)

The indexing and alignment for RNA Velocity can easily be performed with [the scRNA-seq workflow of seq2science](https://vanheeringen-lab.github.io/seq2science/content/workflows/scrna_seq.html).
