#!/usr/bin/bash

# USAGE: get table of gene ID's and their corresponding DNA sequences
# extract DNA seq from genbank file using the gene ID. See `dna_from_gbk.py` for details
# WARN: make sure the conda env is activated!

### NIFE LSU #############################

# STEP 1: make the index of gene ID's and their respective genbank file paths
find . -type f -name "*genomic_region.gbk" | while read -r genbankpath; do
    # get just the gene id from the gbk path, i.e., stemname
    gene_id=${genbankpath%-*}
    gene_id=${gene_id##*/}
    # echo out the index
    echo -e "${gene_id}\t${genbankpath}"
done >index_lsu_gbk.tsv

# STEP 2: run the python script, but use parallel for speed
parallel --colsep '\t' python ~/bin/dna_from_gbk.py -i {1} -g {2} :::: index_lsu_gbk.tsv >nife_LSU_DNA_seq.tsv

### NIFE SSU ##########################

# STEP 1: make the index of gene ID's and their respective genbank file paths
# NOTE: requires a slightly different procedure from just getting the LSU gene ID from the genbank filename
find . -type f -name "*genomic_region.gbk" | while read -r genbankpath; do
    # get the parentdir
    parentdir=${genbankpath%/*}
    # find the SSU fasta file in the parentdir
    ssu_id=$(find "${parentdir}" -type f -name "*NiFe_SSU*")
    # extract just the gene ID from this filename
    ssu_id=${ssu_id##*/}
    ssu_id=${ssu_id%%-*}
    # echo out the index
    echo -e "${ssu_id}\t${genbankpath}"
done >index_ssu_gbk.tsv

# STEP 2: run the python script, but use parallel for speed
parallel --colsep '\t' python ~/bin/dna_from_gbk.py -i {1} -g {2} :::: index_ssu_gbk.tsv >nife_SSU_DNA_seq.tsv
