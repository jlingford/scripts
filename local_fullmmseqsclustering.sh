#!/usr/bin/bash

# NOTE: cov-mode 0 and cluster-mode 0 is a bidirectional coverage mode & greedy style clustering. cov-mode 0 = query and target must cover x% of each other, i.e. clusters by lengths. useful to find full-length protein representatives
# NOTE: cov-mode 1 and cluster-mode 2 is a target coverage mode & CD-HIT style clustering. cov-mode 1 = query must cover x% of target, i.e. hoovers up short proteins and returns largest protein for each cluster. recommended to run cov-mode 1 with cluster-mode 2
# NOTE: cov-mode 0 and cluster-mode 1 is a bidirectional coverage mode & remote homolog style clustering. keeps more distant homologs in a cluster rather than separating them into many smaller clusters.
# NOTE: cov-mode 2 = query coverage mode (i.e. target must cover x% of query seq.). reccomended for mmseqs search, but not really applicable to clustering.
# NOTE: cov-mode 3 = target must be x% length of query. could be useful for downstream MSA generation.

# set THREADS usage
T=12

# step 0: place fasta files for clustering in ./fastainput directory
# step 1 (done): create sequenceDB out of fastas
for file in ./fastainput/*.faa; do
    if [[ ! -d seqDB ]]; then
        mkdir -p seqDB
    fi
    name=${file##*/}
    name=${name%.*}
    mmseqs createdb \
        ./fastainput/${name}.faa \
        ./seqDB/${name}-DB \
        --dbtype 1
done

# set protein name and seq ids and query/target coverages to loop over
protein_names=(
    $(for file in ./fastainput/*.faa; do
        name=${file##*/}
        name=${name%.*}
        echo $name
    done)
)
# seq_ids=("0.00" "0.10" "0.20" "0.30" "0.40" "0.50" "0.60" "0.70" "0.80" "0.90")
seq_ids=("0.20" "0.30" "0.50" "0.70")
# coverages=("0.50" "0.60" "0.70" "0.80" "0.90")
coverages=("0.80")

# START CLUSTERING
# set cov-mode and cluster-mode
echo "SETTING CLUSTERING: COV-MODE 1; CLUST-MODE 2"
COVMODE=1
CLUSTMODE=2
suffix3=${COVMODE}
suffix4=${CLUSTMODE}

# set query/target coverage
for cov in "${coverages[@]}"; do
    COV=${cov}
    suffix1=${COV##*.}
    echo "SETTING COVERAGE COVERAGE: ${COV}%"

    # set query fastas to cluster
    for name in "${protein_names[@]}"; do

        # set seqid limit to cluster at
        for id in "${seq_ids[@]}"; do

            SEQID="${id}"
            suffix2=${SEQID##*.}
            echo "SETTING SEQID: ${SEQID}%"

            # set long database name
            DBNAME=${name}-covm${suffix3}-clustm${suffix4}-cov${suffix1}-id${suffix2}

            # make directories if they don't exist yet
            directories=("seqDB" "clustDB" "alignDB" "fastaclustDB" "repclustDB" "outfiles")
            for dir in "${directories[@]}"; do
                if [[ ! -d ${dir}/${name} ]]; then
                    mkdir -p ${dir}/${name}
                fi
            done
            # need to create separate tmp dirs for each loop to prevent this issue: https://github.com/soedinglab/MMseqs2/issues/607
            if [[ ! -d tmp ]]; then
                mkdir -p tmp
            fi
            if [[ ! -d outfiles/${name}/${DBNAME} ]]; then
                mkdir -p outfiles/${name}/${DBNAME}
            fi

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
                -e 0.001 \
                -a 1 \
                --threads ${T}

            # step 3: output tsv of clusters
            mmseqs createtsv \
                ./seqDB/${name}-DB \
                ./clustDB/${name}/${DBNAME} \
                ./outfiles/${name}/${DBNAME}/${DBNAME}-clust_info.tsv \
                --threads ${T}

            # optional step 4: create alignment (2 steps)
            # optional step 4.1: convert clusterDB to alignmentDB
            mmseqs align \
                ./seqDB/${name}-DB \
                ./seqDB/${name}-DB \
                ./clustDB/${name}/${DBNAME} \
                ./alignDB/${name}/${DBNAME} \
                -a 1 \
                --threads ${T}

            # step 4.2: convert alignmentDB to alignment output file
            mmseqs convertalis \
                ./seqDB/${name}-DB \
                ./seqDB/${name}-DB \
                ./alignDB/${name}/${DBNAME} \
                ./outfiles/${name}/${DBNAME}/${DBNAME}-all_clusters.tsv \
                --format-mode 4 \
                --format-output query,target,evalue,pident,tseq \
                --threads ${T}

            # creating fasta files...

            # step 5: convert cluster to fasta files (2 steps)
            # step 5.1: convert clusterDB to fasta-clusterDB
            mmseqs createseqfiledb \
                ./seqDB/${name}-DB \
                ./clustDB/${name}/${DBNAME} \
                ./fastaclustDB/${name}/${DBNAME} \
                --threads ${T}

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
            rename "s/.faa/-${COUNT}_seqs.faa/" outfiles/${name}/${DBNAME}/${DBNAME}-clust_representatives.faa

            # run split fasta python script
            # ./mmseqsfasta2splitfasta.py outfiles/${name}/${DBNAME}/${DBNAME}.faa

            echo "done!"

            rm -rf tmp/*

        done
    done
    # output cluster reps counts to tsv file (requires "fd" to be installed)
    fd seqs.faa | awk -F"/" '{print $NF}' | sort | awk -F"-" -vOFS="\t" '{print $1, $(NF-6), $(NF-5), $(NF-3), $(NF-2), $(NF-4),  $NF}' | sed 's/id//' | sed 's/_seqs.faa//' | sed '1i #name\tdetails\tcoverage\tcov-mode\tcluster-mode\tseqid\tno_rep_seqs' >./outfiles/cluster_counts-covm${suffix3}-clustm${suffix4}-cov${suffix1}.tsv
    # compress/archive results files
    # echo "ARCHIVING RESULTS..."
    # tar -czvf ./outfiles/clustering-covm${suffix3}-clustm${suffix4}-cov${suffix1}.tar.gz --exclude="*.gz" ./outfiles/*
    # remove unarchived files:
    # for file in ./fastainput/*.faa; do
    #     name=${file##*/}
    #     name=${name%.*}
    #     rm -rf ./outfiles/${name}
    # done
    # rm ./outfiles/*.tsv
done

echo "DONE!"
# rm -rf tmp/*
