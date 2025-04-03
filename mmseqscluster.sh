#!/usr/bin/bash

# need to have mmseqs conda environment activated!
# usage: ./script.sh
# RUN FROM CORRECT BASE DIRECTORY TO NOT CLUTTER UP DISK

# variables
COV=0.80
SEQID=0.90
COVMODE=0
CLUSTMODE=0
suffix1=${COV##*.}
suffix2=${SEQID##*.}
suffix3=${COVMODE}
suffix4=${CLUSTMODE}

# mamba activate mmseqs2

protein_names=("fefe" "feon" "nife")
for name in "${protein_names[@]}"; do

    # set long database name
    DBNAME=${name}-cov${suffix1}-id${suffix2}-covm${suffix3}-clustm${suffix4}

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
    if [[ ! -d outfiles/${name}/${DBNAME} ]]; then
        mkdir -p outfiles/${name}/${DBNAME}
    fi

    # # step 1 (done): create sequenceDB out of fastas
    # mmseqs createdb \
    #     ./YOUR_FASTA_FILE.faa \
    #     ./seqDB/${name}-DB \
    #     --dbtype 1

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
        --max-seqs 300 \
        -s 7.5 \
        -e 0.0001 \
        -a 1

    # step 3: output tsv of clusters
    mmseqs createtsv \
        ./seqDB/${name}-DB \
        ./clustDB/${name}/${DBNAME} \
        ./outfiles/${name}/${DBNAME}/${DBNAME}-clust_info.tsv

    # optional step 4: create alignment (2 steps)
    # optional step 4.1: convert clusterDB to alignmentDB
    mmseqs align \
        ./seqDB/${name}-DB \
        ./seqDB/${name}-DB \
        ./clustDB/${name}/${DBNAME} \
        ./alignDB/${name}/${DBNAME} \
        -a 1

    # step 4.2: convert alignmentDB to alignment output file
    mmseqs convertalis \
        ./seqDB/${name}-DB \
        ./seqDB/${name}-DB \
        ./alignDB/${name}/${DBNAME} \
        ./outfiles/${name}/${DBNAME}/${DBNAME}-all_clusters.tsv \
        --format-mode 4 \
        --format-output query,target,evalue,pident,tseq

    # creating fasta files...

    # step 5: convert cluster to fasta files (2 steps)
    # step 5.1: convert clusterDB to fasta-clusterDB
    mmseqs createseqfiledb \
        ./seqDB/${name}-DB \
        ./clustDB/${name}/${DBNAME} \
        ./fastaclustDB/${name}/${DBNAME}

    # step 5.2: covert fasta-clusterDB to fasta file
    mmseqs result2flat \
        ./seqDB/${name}-DB \
        ./seqDB/${name}-DB \
        ./fastaclustDB/${name}/${DBNAME} \
        ./outfiles/${name}/${DBNAME}/${DBNAME}.faa

    # step 6: retrieve representative sequences from clusters (2 steps)
    # step 6.1: convert clusterDB to cluster_representativesDB
    mmseqs createsubdb \
        ./clustDB/${name}/${DBNAME} \
        ./seqDB/${name}-DB \
        ./repclustDB/${name}/${DBNAME}-clust_representatives

    # step 6.2: convert cluster_representativesDB to fasta file
    mmseqs convert2fasta \
        ./repclustDB/${name}/${DBNAME}-clust_representatives \
        ./outfiles/${name}/${DBNAME}/${DBNAME}-clust_representatives.faa

    # rename -cluster_representatives.faa to contain number of fasta files in name
    COUNT=$(grep -c "^>" outfiles/${name}/${DBNAME}/${DBNAME}-clust_representatives.faa)
    perl-rename "s/.faa/-${COUNT}_seqs.faa/" outfiles/${name}/${DBNAME}/${DBNAME}-clust_representatives.faa

    # run split fasta python script
    mmseqsfasta2splitfasta.py outfiles/${name}/${DBNAME}/${DBNAME}.faa

    echo "done!"

done

rm -rf tmp/*
