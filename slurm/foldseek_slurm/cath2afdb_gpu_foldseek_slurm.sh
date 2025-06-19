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
# --- #SBATCH --partition=gpu
# --- #SBATCH --qos=bdiq

# install gpu foldseek (do once)
# wget https://mmseqs.com/foldseek/foldseek-linux-gpu.tar.gz
# tar xvfz foldseek-linux-gpu.tar.gz --one-top-level

# activate env
module purge
export PATH=$(pwd)/foldseek-linux-gpu/foldseek/bin/:$PATH

# define variables
DBDIR="/home/jamesl/rp24_scratch/Database/FoldSeek/GPU_DATABASES"
PROSTT5DIR="/home/jamesl/rp24_scratch/Database/FoldSeek/ProstT5"

# set file input
INPUTLOOP=(
    # './input/fefe_hyddb1-covm0-clustm0-cov80-id80-clust_representatives-825_seqs.faa'
    # './input/nife_hyddb1-covm0-clustm0-cov80-id80-clust_representatives-1006_seqs.faa'
    # './input/gtdb/fefe-gtdb226-withmotif-combined2-covm0-clustm0-cov80-id50-clust_representatives-1271_seqs.faa'
    # './input/gtdb/nife-gtdb226-withmotif-combined2-covm0-clustm0-cov80-id50-clust_representatives-400_seqs.faa'
    # './input/gtdb/feon-gtdb226-combined2-covm0-clustm0-cov80-id50-clust_representatives-1_seqs.faa'
    # './input/gtdb/feon-gtdb226-combined3-covm0-clustm0-cov80-id50-clust_representatives-67_seqs.faa'
    # './input/gtdb/nife-gtdb226-withmotif-combined3-covm0-clustm0-cov80-id50-clust_representatives-1036_seqs.faa'
    # './input/gtdb/fefe-gtdb226-withmotif-combined3-covm0-clustm0-cov80-id50-clust_representatives-2606_seqs.faa'
    # './input/gtdb/feon-gtdb226-combined2-covm1-clustm2-cov80-id70-clust_representatives-4_seqs.faa'
    # './input/gtdb/nife-gtdb226-withmotif-combined2-covm1-clustm2-cov80-id70-clust_representatives-4809_seqs.faa'
    # './input/gtdb/fefe-gtdb226-withmotif-combined2-covm1-clustm2-cov80-id70-clust_representatives-8079_seqs.faa'
    './input/gtdb/fefe-gtdb226-withmotif-combined2-covm0-clustm0-cov80-id30-clust_representatives-160_seqs.faa'
    './input/gtdb/fefe-gtdb226-withmotif-combined3-covm0-clustm0-cov80-id30-clust_representatives-413_seqs.faa'
    './input/gtdb/feon-gtdb226-combined2-covm0-clustm0-cov80-id30-clust_representatives-1_seqs.faa'
    './input/gtdb/feon-gtdb226-combined3-covm0-clustm0-cov80-id30-clust_representatives-42_seqs.faa'
    './input/gtdb/nife-gtdb226-withmotif-combined2-covm0-clustm0-cov80-id30-clust_representatives-33_seqs.faa'
    './input/gtdb/nife-gtdb226-withmotif-combined3-covm0-clustm0-cov80-id30-clust_representatives-175_seqs.faa'
)

# set job name
# WARN: change this each run:
JOBNAME='gtdb_covm00cov80id30'

# databases to query
DB1='CATH50_gpu'
# DB2='UniProt_gpu'
DB2='UniProt50_gpu'
# DB2='UniProt50-minimal_gpu'

# run workflow
for INPUT in "${INPUTLOOP[@]}"; do
    # set file names
    name=${INPUT##*/}
    name=${name%.*}
    dbname=${DB2##*/}
    dbname=${dbname,,}
    jobname=${JOBNAME,,}-${dbname}

    # make output dirs if they don't exist
    dirlist=(
        "queryDB/${jobname}"
        "cathhitsDB/${jobname}"
        "outfiles/${jobname}"
        "subset_dir/${jobname}/"
        "afdbhitsDB/${jobname}"
        "pdboutput/${jobname}/${name}"
    )
    for dir in "${dirlist[@]}"; do
        if [[ ! -d ${dir} ]]; then
            mkdir -p $dir
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

    # STEP 2:
    # search the AFDB using the subset of prostt5-models that contain the CATH domain of interest
    foldseek search \
        ./queryDB/${jobname}/${name}-subset \
        ${DBDIR}/$DB2 \
        ./afdbhitsDB/${jobname}/${name} \
        ./tmp \
        -s 9.5 \
        -a 1 \
        --gpu 1 \
        --remove-tmp-files

    # extract results
    foldseek convertalis \
        ./queryDB/${jobname}/${name}-subset \
        ${DBDIR}/$DB2 \
        ./afdbhitsDB/${jobname}/${name} \
        ./outfiles/${jobname}/${name}-AFDB_HITS_RAW.tsv \
        --format-mode 0

    # filter afdb tsv results
    sort -u -k1,1 ./outfiles/${jobname}/${name}-AFDB_HITS_RAW.tsv >./outfiles/${jobname}/${name}-AFDB_TOP_HITS.tsv
    # create a list of unique afdb hits
    sort -u -k2,2 ./outfiles/${jobname}/${name}-AFDB_TOP_HITS.tsv >./outfiles/${jobname}/${name}-AFDB_UNIQUE_HITS.tsv

    # make log file
    wc -l ./outfiles/${jobname}/${name}-AFDB_TOP_HITS.tsv >>./outfiles/${jobname}/count.txt
    wc -l ./outfiles/${jobname}/${name}-AFDB_UNIQUE_HITS.tsv >>./outfiles/${jobname}/count.txt

    # make subset list of unique afdb hits to grep afdbhitsDB with
    # NOTE: make sure to select 2nd field containing AFDB ID's
    cut -f2 ./outfiles/$jobname/${name}-AFDB_UNIQUE_HITS.tsv >./subset_dir/${jobname}/${name}-AFDB_subset_list.txt
    # NOTE: grep the AFDB database, not the alignmentDB "afdbhitsDB" (which does not contain any Ca info)
    grep -f ./subset_dir/${jobname}/${name}-AFDB_subset_list.txt ${DBDIR}/${DB2}.lookup >./subset_dir/${jobname}/${name}-AFDB_subsetDB.tsv

    # createsubdb of unique AFDB hits
    foldseek createsubdb \
        ./subset_dir/${jobname}/${name}-AFDB_subsetDB.tsv \
        ${DBDIR}/$DB2 \
        ./afdbhitsDB/${jobname}/${name}-subset

    # extract Ca PDB files of unique AFDB hits
    foldseek convert2pdb \
        ./afdbhitsDB/${jobname}/${name}-subset \
        ./pdboutput/${jobname}/${name}/ \
        --pdb-output-mode 1

    # zip pdb files to outfiles dir
    zip -r ./outfiles/${jobname}/${name%%-*}-Ca_pdbs.zip ./pdboutput/${jobname}/${name}/
    # copy input fasta to outfile dir
    cp $INPUT ./outfiles/${jobname}

    echo "Finished foldseek for ${INPUT}"
done

# rm -rf tmp/*
