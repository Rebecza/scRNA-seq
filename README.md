# scRNA-seq
From fastq to preprocessed counttable (in-house CELSeq2 method), with Kallisto | Bustools workflow.

![FlowChart_scRNA-seqPreprocessing_sm](https://user-images.githubusercontent.com/56538023/114436621-d804fc00-9bc5-11eb-8dcf-45433f548aa5.png)


# Running the alignment needed for RNA Velocity #


**The indexing and alignment for RNA Velocity can be performed with [the scRNA-seq workflow of seq2science](https://vanheeringen-lab.github.io/seq2science/content/workflows/scrna_seq.html).**

Alternatively, by hand: 

Using the kb-wrapper in a conda environment. All paths lead to the files where I have stored them, copy those and change path accordingly.

Install conda environment with the following file: kb_scrna.yaml. By running:

`conda env create -f /home/path_to_file/kb_scrna.yaml`

(For faster installation you can also install `mamba` in your base environment of conda. After this, substitute `conda` in the line above with `mamba` and the installing of your environment becomes much quicker. `mamba` also works for installation of single packages!)

## Create the Velocity index: 

*Run in the folder where you want the output!*

For the human genome this looks like this:

```bash {cmd}
kb ref -i GRCh38_index.idx -g GRCh38_t2g.txt -f1 GRCh38_cdna.fa -f2 GRCh38_intron.fa -c1 GRCh38_cdna_t2c.txt -c2 GRCh38_intron_t2c.txt --lamanno ../path_to_file/path_to_file/Homo_sapiens.GRCh38.dna.ercc_reporter.fa ../path_to_file/Homo_sapiens.GRCh38.99.ercc_reporter.gtf
```

This function only needs the fastq of the genome + the corresponding gtf. With these files the function will generate a separate intronic and cDNA .fa file, followed by an index created for the combination of both together. Arguments -i, -g, -f1 and -f2 need the wanted names for the output files. The .idx will contain the index, t2g.txt the transcript identifiers and corresponding gene name f1 and f2 are the names for the two .fa files it will generate. --lamanno defines the type of index you want to generate, in this case a RNA-velocity index. This refers to the first author of the RNA Velocity paper, La Manno.
See for more info on the arguments: https://www.kallistobus.tools/introduction


## Run the alignment:
kb-wrapper is an easy to use package that combines Kallisto and Bustools functions. I wrote a little bash script that will run the kb-wrapper with the right settings for the SORT-seq protocol in our lab this will run over all fastqs in the specified folder (with the argument -f or --fastqpath) and align for further processing with RNA-Velocity. It will also generate a **log.out file**, in which all the command line output will be stored.
For human genomes, one can leave the default locations (if you're running from our server) for the genome. The ERCC spike-ins and most common reporters, are included in this index. 

Download the `running_kbvelocity.sh` and `1col_barcode_384.tab`, and check if the files and there locations in the top of the script are present.

**To make sure the bash script is runnable**

`chmod +x /home/path_to_file/running_kbvelocity.sh`

*Run in the folder where you want the output!*

Run the alignment with "running_kbvelocity.sh" and argument -f the path to folder with the .fastqs. (It is advisable to do this in a `screen`, since this process takes a while)
`/home/path_to_file/running_kbvelocity.sh -f /home/path_to_files/data/`
By repeating to run this step, you can check if the mapping was performed for all the fastqs in your location. It will give you a list of plates the alignment was done for, and if a plate/fastq is missing, this will be run again.
