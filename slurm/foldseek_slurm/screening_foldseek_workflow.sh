#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J GPU_FoldSeek
#SBATCH --mem=80000
#SBATCH --time=48:00:00
#SBATCH --gres=gpu:L40S:1
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
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

# set job name
# WARN: change this each run:
JOBNAME='globdb_hmmer_mmseqs_covm12cov80id50_cathscreen'

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
    # './input/gtdb/feon-gtdb226-combined3-covm0-clustm0-cov80-id70-clust_representatives-131_seqs.faa'
    # './input/gtdb/nife-gtdb226-withmotif-combined3-covm0-clustm0-cov80-id70-clust_representatives-7199_seqs.faa'
    # './input/gtdb/fefe-gtdb226-withmotif-combined3-covm0-clustm0-cov80-id70-clust_representatives-13923_seqs.faa'
    './input/globdb_hmmer_mmseqs/fefe-globdb226_hmmer_mmseqs_hits-cov80-id50-covm1-clustm2-clust_representatives-6500_seqs.faa'
    './input/globdb_hmmer_mmseqs/feon-globdb226_hmmer_mmseqs-cov80-id50-covm1-clustm2-clust_representatives-1199_seqs.faa'
    './input/globdb_hmmer_mmseqs/nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id50-covm1-clustm2-clust_representatives-8266_seqs.faa'
)

# define paths to databases
DBDIR="/home/jamesl/rp24_scratch/Database/FoldSeek/GPU_DATABASES"
PROSTT5DIR="/home/jamesl/rp24_scratch/Database/FoldSeek/ProstT5"

# databases to query
DB1='CATH50_gpu'

DB2LOOP=(
    'PDB_gpu'
    'ESMAtlas30_gpu'
    # 'UniProt_gpu'
    'UniProt50_gpu'
    # 'UniProt50-minimal_gpu'
)

# run workflow
for INPUT in "${INPUTLOOP[@]}"; do
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

    # STEP 2:
    # search the AFDB or other database using the subset of prostt5-models that contain the CATH domain of interest
    for DB2 in "${DB2LOOP[@]}"; do
        # set var names
        dbname=${DB2##*/}
        dbname=${dbname/_gpu/}
        dbname=${dbname^^}

        # make pdboutput dir
        if [[ ! -d pdboutput/${jobname}/${name}-${dbname} ]]; then
            mkdir -p "pdboutput/${jobname}/${name}-${dbname}"
        fi

        foldseek search \
            ./queryDB/${jobname}/${name}-subset \
            ${DBDIR}/$DB2 \
            ./afdbhitsDB/${jobname}/${name}-${dbname} \
            ./tmp \
            -s 9.5 \
            -a 1 \
            --gpu 1 \
            --remove-tmp-files

        # extract results
        foldseek convertalis \
            ./queryDB/${jobname}/${name}-subset \
            ${DBDIR}/$DB2 \
            ./afdbhitsDB/${jobname}/${name}-${dbname} \
            ./outfiles/${jobname}/${name}-${dbname}_HITS_RAW.tsv \
            --format-mode 0

        # filter afdb tsv results
        sort -u -k1,1 ./outfiles/${jobname}/${name}-${dbname}_HITS_RAW.tsv >./outfiles/${jobname}/${name}-${dbname}_TOP_HITS.tsv
        # create a list of unique afdb hits
        sort -u -k2,2 ./outfiles/${jobname}/${name}-${dbname}_TOP_HITS.tsv >./outfiles/${jobname}/${name}-${dbname}_UNIQUE_HITS.tsv

        # make log file
        wc -l ./outfiles/${jobname}/${name}-${dbname}_TOP_HITS.tsv >>./outfiles/${jobname}/count.txt
        wc -l ./outfiles/${jobname}/${name}-${dbname}_UNIQUE_HITS.tsv >>./outfiles/${jobname}/count.txt

        # make subset list of unique afdb hits to grep afdbhitsDB with
        # NOTE: make sure to select 2nd field containing AFDB ID's
        cut -f2 ./outfiles/${jobname}/${name}-${dbname}_UNIQUE_HITS.tsv >./subset_dir/${jobname}/${name}-${dbname}_subset_list.txt
        # NOTE: grep the AFDB database, not the alignmentDB "afdbhitsDB" (which does not contain any Ca info)
        grep -f ./subset_dir/${jobname}/${name}-${dbname}_subset_list.txt ${DBDIR}/${DB2}.lookup >./subset_dir/${jobname}/${name}-${dbname}_subsetDB.tsv

        # createsubdb of unique AFDB hits
        foldseek createsubdb \
            ./subset_dir/${jobname}/${name}-${dbname}_subsetDB.tsv \
            ${DBDIR}/$DB2 \
            ./afdbhitsDB/${jobname}/${name}-${dbname}-subset

        # extract Ca PDB files of unique AFDB hits
        foldseek convert2pdb \
            ./afdbhitsDB/${jobname}/${name}-${dbname}-subset \
            ./pdboutput/${jobname}/${name}-${dbname}/ \
            --pdb-output-mode 1

        # zip pdb files to outfiles dir
        zip -r ./outfiles/${jobname}/${name%%-*}-${dbname}_Ca_pdbs.zip ./pdboutput/${jobname}/${name}-${dbname}/

    done

    # copy input fasta to outfile dir
    cp $INPUT ./outfiles/${jobname}
    cp ./subset_dir/${jobname}/${name}-CATH50_subset_list.txt ./outfiles/${jobname}

    echo "Finished foldseek for ${INPUT}"
done

# rm -rf tmp/*
