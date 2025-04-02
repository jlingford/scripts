#!/usr/bin/bash

# need to have mmseqs conda environment activated!
# usage: ./script.sh

# variables
COV=0.80
SEQID=0.20
COVMODE=0
CLUSTMODE=0
suffix1=${COV##*.}
suffix2=${SEQID##*.}
suffix3=${COVMODE}
suffix4=${CLUSTMODE}

# mamba activate mmseqs2

protein_names=("fefe" "feon" "nife")
for name in "${protein_names[@]}"; do

    # make directories if they don't exist yet
    directories=("seqDB" "clustDB" "alignDB" "fastaclustDB" "repclustDB" "outfiles")
    for dir in "${directories[@]}"; do
        if [[ ! -d ${dir}/${name} ]]; then
            mkdir -p ${dir}/${name}
        fi
    done
    if [[ ! -d tmp ]]; then
        mkdir -p tmp
    fi

    # set long database name
    DBNAME=${name}-cov${suffix1}-id${suffix2}-covm${suffix3}-clustm${suffix4}

    # step 1 (done): create sequenceDB out of fastas

    # step 2: create cluster database
    mmseqs cluster \
        ./seqDB/${name}-DB \
        ./clustDB/${name}/${DBNAME} \
        ./tmp \
        --remove-tmp-files 1 \
        -c ${COV} \
        --min-seq-id ${SEQID} \
        --cov-mode ${COVMODE} \
        --cluster-mode ${CLUSTMODE} \
        --max-seqs 20 \
        -s 7.5 \
        -e 0.0001 \
        -a 1

    # step 3: output tsv of clusters
    mmseqs createtsv \
        ./seqDB/${name}-DB \
        ./clustDB/${name}/${DBNAME} \
        ./outfiles/${name}/${DBNAME}-clust_info.tsv

    # step 4: convert clusterDB to alignmentDB
    mmseqs align \
        ./seqDB/${name}-DB \
        ./seqDB/${name}-DB \
        ./clustDB/${name}/${DBNAME} \
        ./alignDB/${name}/${DBNAME} \
        -a 1

    # step 5: convert alignmentDB to alignment output file
    mmseqs convertalis \
        ./seqDB/${name}-DB \
        ./seqDB/${name}-DB \
        ./alignDB/${name}/${DBNAME} \
        ./outfiles/${name}/${DBNAME}-all_clusters.tsv \
        --format-mode 4 \
        --format-output query,target,evalue,pident,tseq

    # creating fasta files...

    # optional step 6: convert cluster to fasta files (2 steps)
    # optional step 6.1: convert clusterDB to fasta-clusterDB
    mmseqs createseqfiledb \
        ./seqDB/${name}-DB \
        ./clustDB/${name}/${DBNAME} \
        ./fastaclustDB/${name}/${DBNAME}

    # optional step 6.2: covert fasta-clusterDB to fasta file
    mmseqs result2flat \
        ./seqDB/${name}-DB \
        ./seqDB/${name}-DB \
        ./fastaclustDB/${name}/${DBNAME} \
        ./outfiles/${name}/${DBNAME}.faa

    # optional step 7: retrieve representative sequences from clusters (2 steps)
    # optional step 7.1: convert clusterDB to cluster_representativesDB
    mmseqs createsubdb \
        ./clustDB/${name}/${DBNAME} \
        ./seqDB/${name}-DB \
        ./repclustDB/${name}/${DBNAME}-clust_representatives

    # optional step 7.2: convert cluster_representativesDB to fasta file
    mmseqs convert2fasta \
        ./repclustDB/${name}/${DBNAME}-clust_representatives \
        ./outfiles/${name}/${DBNAME}-clust_representatives.faa

    echo "done!"

done
