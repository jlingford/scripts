#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J FoldSeek
#SBATCH --mem=367000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --account=rp24
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=4:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

# activate env
# module purge
# module load miniforge3
# conda activate /fs04/rp24/scratch_nobackup/jamesl/rp24_scratch2/jamesl2/miniconda/conda/envs/foldseek

# or use local install
export PATH=$(pwd)/foldseek/bin/:$PATH

# define variables
DATE=$(date +%y%m%d)

# database directories
DBDIR="/home/jamesl/rp24_scratch/Database/FoldSeek"
PROSTT5DIR="/home/jamesl/rp24_scratch/Database/FoldSeek/ProstT5"

# # installed databases, choose one to search
DB="PDB"
# DB="BFMD"
# DB="CATH50"
# DB="ProstT5"
# DB="ESMAtlas30"
# DB="Alphafold/UniProt"
# DB="Alphafold/UniProt50"
# DB="Alphafold/UniProt50-minimal"

# set file input
# INPUT="./input/fefe-gtdb226-withmotif-combined2-covm1-clustm2-cov80-id30-clust_representatives-76_seqs.faa"
INPUT="./input/test.pdb"

# set file & dir names
name=${INPUT##*/}
name=${name%.*}
dbname=${DB##*/}
dbname=${dbname,,}
jobname=${name%%-*}_${dbname}

# make output dir if it doesn't exist
if [[ ! -d ./output/$jobname ]]; then
    mkdir -p ./output/$jobname
fi
if [[ ! -d ./queryDB_ProstT5/$jobname ]]; then
    mkdir -p ./queryDB_ProstT5/$jobname
fi
if [[ ! -d ./queryDB/$jobname ]]; then
    mkdir -p ./queryDB/$jobname
fi
if [[ ! -d ./PDB_output/$jobname ]]; then
    mkdir -p ./PDB_output/$jobname
fi
if [[ ! -d ./resultDB/$jobname ]]; then
    mkdir -p ./resultDB/$jobname
fi

# # foldseek
# foldseek createdb \
#     $INPUT \
#     ./queryDB_ProstT5/$jobname/test3 \
#     --threads 95 \
#     --prostt5-model $PROSTT5DIR

# foldseek
foldseek createdb \
    $INPUT \
    ./queryDB/$jobname/test3 \
    --threads 95

foldseek search \
    ./queryDB/$jobname/test3 \
    $DBDIR/$DB \
    ./resultDB/$jobname/test3 \
    ./tmp \
    -s 9.5 \
    -a 1 \
    --threads 95 \
    --remove-tmp-files

foldseek convertalis \
    ./queryDB/$jobname/test3 \
    $DBDIR/$DB \
    ./resultDB/$jobname/test3 \
    ./output/$jobname/test3.tsv \
    --format-mode 0 \
    --threads 95

foldseek convert2pdb \
    ./resultDB/$jobname/test3 \
    ./PDB_output/$jobname/test3 \
    --threads 95 \
    --pdb-output-mode 0

# # easy-search default output
# foldseek easy-search \
#     $INPUT \
#     $DBDIR/$DB \
#     ./output/${jobname}/${name}-${dbname}.tsv \
#     ./tmp \
#     -s 7.5 \
#     -e 1e-5 \
#     --threads 95 \
#     --prostt5-model $PROSTT5DIR \
#     --format-mode 0

# # setup databases
# foldseek databases $DB $DBDIR/$DB ./tmp

# easy-search .tsv output
# foldseek easy-search \
#     ./input/feon_gtdb226-cov80-id80-covm0-clustm0-clust_representatives-15_seqs.faa \
#     $DBDIR/$DB \
#     ./output/Feonly_test32 \
#     ./tmp \
#     -s 7.5 \
#     -e 1e-5 \
#     --threads 95 \
#     --prostt5-model $PROSTT5DIR \
#     --format-mode 4 \
#     --format-output query,target,taxname,taxid,prob,evalue,pident,rmsd,lddt,qstart,qend,qlen,qcov

# rm -rf tmp/*
