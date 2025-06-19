#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J GPU_FoldSeek
#SBATCH --mem=60000
#SBATCH --time=8:00:00
#SBATCH --gres=gpu:A100:1
#SBATCH --partition=bdi
#SBATCH --qos=bdiq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --account=rp24
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

# activate env
module purge
# module load miniforge3
# conda activate /fs04/scratch2/rp24/jamesl2/GPU_mmseqs2/rp24_scratch2/jamesl2/miniconda/conda/envs/nvcc

# install gpu foldseek (do once)
# wget https://mmseqs.com/foldseek/foldseek-linux-gpu.tar.gz
# tar xvfz foldseek-linux-gpu.tar.gz --one-top-level
# set path
export PATH=$(pwd)/foldseek-linux-gpu/foldseek/bin/:$PATH

# define variables
DATE=$(date +%y%m%d)

DBDIR="/home/jamesl/rp24_scratch/Database/FoldSeek/GPU_DATABASES"
CPUDIR="/home/jamesl/rp24_scratch/Database/FoldSeek"
PROSTT5DIR="/home/jamesl/rp24_scratch/Database/FoldSeek/ProstT5"

# INPUT=
# OUTPUT="Feonly_easysearch.tsv"

# # installed CPU databases, convert to GPU database once
# CPUDB="PDB"
# CPUDB="BFMD"
# CPUDB="CATH50"
# CPUDB="ProstT5"
# CPUDB="ESMAtlas30"
# CPUDB="Alphafold/UniProt"
# CPUDB="Alphafold/UniProt50"
# CPUDB="Alphafold/UniProt50-minimal"

# # installed GPU databases, choose one to search
# DB="PDB_gpu" # made it
# DB="BFMD_gpu"
# DB="CATH50_gpu" # made it
# DB="ESMAtlas30_gpu"
# DB="UniProt_gpu"
# DB="UniProt50_gpu"
# DB="UniProt50-minimal_gpu" # made it

DBLOOP=(
    'UniProt50_gpu'
    'CATH50_gpu'
)
# set file input
INPUTLOOP=(
    # './input/fefe_hyddb1-covm0-clustm0-cov80-id80-clust_representatives-825_seqs.faa'
    # './input/nife_hyddb1-covm0-clustm0-cov80-id80-clust_representatives-1006_seqs.faa'
    './input/gtdb/fefe-gtdb226-withmotif-combined2-covm0-clustm0-cov80-id50-clust_representatives-1271_seqs.faa'
    './input/gtdb/nife-gtdb226-withmotif-combined2-covm0-clustm0-cov80-id50-clust_representatives-400_seqs.faa'
)

jobname='gtdb_covm00_cov80_id50'
for DB in "${DBLOOP[@]}"; do
    for INPUT in "${INPUTLOOP[@]}"; do
        # set file names
        name=${INPUT##*/}
        name=${name%.*}
        dbname=${DB##*/}
        dbname=${dbname,,}
        # jobname=${name%%-*}_${dbname%_*}

        # make output dir if it doesn't exist
        if [[ ! -d ./output/$jobname ]]; then
            mkdir -p ./output/$jobname
        fi

        # easy-search default output
        foldseek easy-search \
            $INPUT \
            $DBDIR/$DB \
            ./output/$jobname/${name}-${dbname%_*}_hits.tsv \
            ./tmp \
            --prostt5-model $PROSTT5DIR \
            --gpu 1 \
            --format-mode 0 \
            -s 9.5

    done
done

# # setup databases
# foldseek databases $DB $DBDIR/$DB ./tmp

# easy-search .tsv output
# foldseek easy-search \
#     ./input/feon_gtdb226-cov80-id80-covm0-clustm0-clust_representatives-15_seqs.faa \
#     $DBDIR/$DB \
#     ./output/Feonly_test2 \
#     ./tmp \
#     -s 7.5 \
#     -e 1e-5 \
#     --threads 95 \
#     --prostt5-model $PROSTT5DIR \
#     --format-mode 4 \
#     --format-output query,target,taxname,taxid,prob,evalue,pident,rmsd,lddt,qstart,qend,qlen,qcov

# rm -rf tmp/*
