#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J GPU_FoldSeek
#SBATCH --mem=80000
#SBATCH --time=8:00:00
#SBATCH --gres=gpu:L40S:1
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --account=rp24
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

# other SLURM options
# --- #SBATCH --gres=gpu:L40S:1
# --- #SBATCH --partition=gpu
# --- #SBATCH --qos=bdiq

# install gpu foldseek (do once)
# wget https://mmseqs.com/foldseek/foldseek-linux-gpu.tar.gz
# tar xvfz foldseek-linux-gpu.tar.gz --one-top-level

# activate env
module purge
export PATH=$(pwd)/foldseek-linux-gpu/foldseek/bin/:$PATH

# set job name
# WARN: change this each run:
JOBNAME='globdb_hmmer_mmseqs_covm12cov80id70_cathscreen'

set file input
INPUTLOOP=(
    # './input/fefe_hyddb1-covm0-hmotif-combined2-covm1-clustm2-cov80-id70-clust_representatives-8079_seqs.faa'
    # './input/globdb_hmmer_mmseqs/fefe-globdb226_hmmer_mmseqs_hits-cov80-id50-covm1-clustm2-clust_representatives-6500_seqs.faa'
    # './input/globdb_hmmer_mmseqs/feon-globdb226_hmmer_mmseqs-cov80-id50-covm1-clustm2-clust_representatives-1199_seqs.faa'
    # './input/globdb_hmmer_mmseqs/nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id50-covm1-clustm2-clust_representatives-8266_seqs.faa'
    './input/globdb_hmmer_mmseqs/id70/fefe-globdb226_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-clust_representatives-43125_seqs.faa'
    './input/globdb_hmmer_mmseqs/id70/feon-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-clust_representatives-4973_seqs.faa'
    './input/globdb_hmmer_mmseqs/id70/nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-clust_representatives-37373_seqs.faa'
)

# define paths to databases
DBDIR="/home/jamesl/rp24_scratch/Database/FoldSeek/GPU_DATABASES"
PROSTT5DIR="/home/jamesl/rp24_scratch/Database/FoldSeek/ProstT5"

# databases to query
DB1='CATH50_gpu'

# run workflow
for INPUT in "${INPUTLOOP[@]}"; do
    # for INPUT in ./input/globdb_hmmer_mmseqs/id70/*.faa; do
    # set file names
    name=${INPUT##*/}
    name=${name%.*}
    jobname=${JOBNAME,,}

    # make output dirs if they don't exist
    dirlist=(
        "queryDB/${jobname}"
        "cathhitsDB/${jobname}"
        "outfiles/${jobname}"
        "subset_dir/${jobname}/"
        "afdbhitsDB/${jobname}"
    )
    for dir in "${dirlist[@]}"; do
        if [[ ! -d ${dir} ]]; then
            mkdir -p "$dir"
        fi
    done

    # STEP 1
    # create prostt5-model db from fasta input
    foldseek createdb \
        $INPUT \
        ./queryDB/${jobname}/${name} \
        --prostt5-model $PROSTT5DIR \
        --gpu 1

    # search prostt5-models against CATH50_gpu database
    foldseek search \
        ./queryDB/${jobname}/${name} \
        ${DBDIR}/$DB1 \
        ./cathhitsDB/${jobname}/${name} \
        ./tmp \
        -s 9.5 \
        -a 1 \
        --gpu 1 \
        --remove-tmp-files

    # extract results
    foldseek convertalis \
        ./queryDB/${jobname}/${name} \
        ${DBDIR}/$DB1 \
        ./cathhitsDB/${jobname}/${name} \
        ./outfiles/${jobname}/${name}-CATH50_HITS_RAW.tsv \
        --format-mode 0

    # filter extracted hits by cath domain presence
    tsv="./outfiles/${jobname}/${name}-CATH50_HITS_RAW.tsv"
    if [[ $tsv == *fefe* ]]; then
        grep -E "3.40.950.10|3.40.50.1780" $tsv | sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
    fi
    if [[ $tsv == *nife* ]]; then
        grep -E "1.10.645.10" $tsv | sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
    fi
    if [[ $tsv == *feon* ]]; then
        grep -E "3.40.50.720" $tsv | sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
    fi

    # make log file
    echo -e "# ${name}" >>./outfiles/${jobname}/count.txt
    echo -e $(grep -c "^>" $INPUT) ${INPUT} >>./outfiles/${jobname}/count.txt
    wc -l ./outfiles/${jobname}/${name}-CATH50_filtered.tsv >>./outfiles/${jobname}/count.txt

    # make subset list file to grep first foldseek queryDB with:
    # NOTE: make sure to select 1st field containing queryDB ID's
    cut -f1 ./outfiles/$jobname/${name}-CATH50_filtered.tsv >./subset_dir/${jobname}/${name}-CATH50_subset_list.txt
    # NOTE: the prostt5-model queryDB does not contain Ca info since it only generates 3Di+aa sequences
    grep -f ./subset_dir/${jobname}/${name}-CATH50_subset_list.txt ./queryDB/${jobname}/${name}.lookup >./subset_dir/${jobname}/${name}-CATH50_subsetDB.tsv

    # createsubdb of queryDB prostt5-models
    foldseek createsubdb \
        ./subset_dir/${jobname}/${name}-CATH50_subsetDB.tsv \
        ./queryDB/${jobname}/$name \
        ./queryDB/${jobname}/${name}-subset

    # copy input fasta and subset list to outfile dir
    cp $INPUT ./outfiles/${jobname}
    cp ./subset_dir/${jobname}/${name}-CATH50_subset_list.txt ./outfiles/${jobname}

    echo "Finished foldseek for ${INPUT}"
done

# rm -rf tmp/*
