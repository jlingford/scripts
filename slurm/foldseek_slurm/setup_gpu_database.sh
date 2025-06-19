#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J GPU_FoldSeek
#SBATCH --mem=80000
#SBATCH --time=4:00:00
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
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
CPUDB="BFMD"
# CPUDB="CATH50"
# CPUDB="ProstT5"
# CPUDB="ESMAtlas30"
# CPUDB="Alphafold/UniProt"
# CPUDB="Alphafold/UniProt50"
# CPUDB="Alphafold/UniProt50-minimal"

# # installed GPU databases, choose one to search
# DB="PDB_gpu" # made it
DB="BFMD_gpu"
# DB="CATH50_gpu" # made it
# DB="ESMAtlas30_gpu" # made it
# DB="UniProt_gpu" # made it
# DB="UniProt50_gpu" # made it
# DB="UniProt50-minimal_gpu" # made it

# # set file input
# INPUT='./input/fefe-gtdb226-withmotif-combined2-covm1-clustm2-cov80-id30-clust_representatives-76_seqs.faa'

# # set file names
# name=${INPUT##*/}
# name=${name%.*}
# dbname=${DB##*/}
# dbname=${dbname,,}
# # jobname=${name%%-*}_${dbname%_*}
# $jobname='testing_uniprot_db'

# # make output dir if it doesn't exist
# if [[ ! -d ./output/$jobname ]]; then
#     mkdir -p ./output/$jobname
# fi

# make gpu database from cpu database
foldseek makepaddedseqdb \
    $CPUDIR/$CPUDB \
    $DBDIR/$DB

# # easy-search default output
# foldseek easy-search \
#     $INPUT \
#     $DBDIR/$DB \
#     ./output/$jobname/${name}-${dbname%_*}_hits.tsv \
#     ./tmp \
#     --remove-tmp-files 1 \
#     --prostt5-model $PROSTT5DIR \
#     --gpu 1 \
#     --format-mode 0 \
#     -s 9.5

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
