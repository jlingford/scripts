#!/usr/bin/bash

# need to have mmseqs conda environment activated
# usage: ./script.sh

#variables
hyd_family=("fefe" "feon" "nife")
COV=0.85
SEQID=0.20
N=10 # keep N many of the biggest clusters corresponding split fasta files
suffix=${COV##*.}
suffix2=${SEQID##*.}

# create cluster database
for hyd in "${hyd_family[@]}"; do

    #step 1 (skipped): create sequenceDB out of fastas

    # create cluster database
    mmseqs cluster \
        ./seqDB/${hyd}-DB \
        ./clustDB/${hyd}/${hyd}-cov${suffix}-id${suffix2} \
        ./tmp \
        --remove-tmp-files 1 \
        -c ${COV} \
        --min-seq-id ${SEQID} \
        --max-seqs 20 \
        -s 7.5 \
        -e 0.0001 \
        -a 1 \
        --cov-mode 0 \
        --cluster-mode 0

    # output tsv of clusters
    mmseqs createtsv \
        ./seqDB/${hyd}-DB \
        ./clustDB/${hyd}/${hyd}-cov${suffix}-id${suffix2} \
        ./out/${hyd}/${hyd}-cov${suffix}-id${suffix2}-clust.tsv

    # convert clusterDB to alignmentDB
    mmseqs align \
        ./seqDB/${hyd}-DB \
        ./seqDB/${hyd}-DB \
        ./clustDB/${hyd}/${hyd}-cov${suffix}-id${suffix2} \
        ./alignDB/${hyd}/${hyd}-cov${suffix}-id${suffix2} \
        -a 1

    # convert alignmentDB to alignment output file
    mmseqs convertalis \
        ./seqDB/${hyd}-DB \
        ./seqDB/${hyd}-DB \
        ./alignDB/${hyd}/${hyd}-cov${suffix}-id${suffix2} \
        ./out/${hyd}/${hyd}-cov${suffix}-id${suffix2}-all_clusters.tsv \
        --format-mode 4 \
        --format-output query,target,evalue,pident,tseq

    # convert cluster to fasta files (2 steps)
    # convert clusterDB to fasta-clusterDB
    mmseqs createseqfiledb \
        ./seqDB/${hyd}-DB \
        ./clustDB/${hyd}/${hyd}-cov${suffix}-id${suffix2} \
        ./fastaclustDB/${hyd}/${hyd}-cov${suffix}-id${suffix2}

    #covert fasta-clusterDB to fasta file
    mmseqs result2flat \
        ./seqDB/${hyd}-DB \
        ./seqDB/${hyd}-DB \
        ./fastaclustDB/${hyd}/${hyd}-cov${suffix}-id${suffix2} \
        ./out/${hyd}/${hyd}-cov${suffix}-id${suffix2}.faa

    # BASH file manipulation
    # splitting .tsv cluster output into separate fasta files
    if [[ ! -d ./out/${hyd}/${hyd}-cov${suffix}-id${suffix2} ]]; then
        mkdir -p ./out/${hyd}/${hyd}-cov${suffix}-id${suffix2}-splitfastas
    fi

    echo "splitting fastas now..."

    # split tsv into separate fasta files based on shared cluster name ($1)
    awk -F'\t' '
        NR>1{
            gsub(/[^a-zA-Z0-9]/, "-", $1)
            printf ">%s\n%s\n", $2,$NF > $1 ".faa"
    }' ./out/${hyd}/${hyd}-cov${suffix}-id${suffix2}-all_clusters.tsv

    # rename file with number of fastas in headers
    for file in *.faa; do
        COUNT=$(grep -c "^>" ${file})
        perl-rename "s/^/${COUNT}-seqsincluster-/" ${file}
    done

    # keep the top N number of split fasta file clusters, and remove the rest
    ls -la | grep .faa | awk '{print $NF}' | sort -gr | tail -n+$((${N} + 1)) | xargs rm

    mv *.faa ./out/${hyd}/${hyd}-cov${suffix}-id${suffix2}-splitfastas

    echo "done ${hyd}!"
done

echo " "
echo "emptying tmp"
rm -rf tmp/*
echo " "
echo "done all!"

## graveyard
# NUM_FASTAS=$(ls -la | awk '{print $NF}' | sed '1,2d' | awk -F"-" -v NUM=${N} '$1<NUM{print}' | wc -l)
#     # echo "Removing ${NUM_FASTAS} with fewer than ${N} seqs..."
#     ls -la | awk '{print $NF}' | sed '1,2d' | awk -F"-" -v NUM=${N} '$1<NUM{print}' | xargs rm
