#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J GPU_FoldSeek
#SBATCH --mem=60000
#SBATCH --time=7-00:00:00
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

## for CPU use
##!/bin/bash -l
##SBATCH -D ./
##SBATCH -J FoldSeek
##SBATCH --mem=367000
##SBATCH --nodes=1
##SBATCH --ntasks-per-node=1
##SBATCH --cpus-per-task=48
##SBATCH --account=rp24
##SBATCH --partition=genomics
##SBATCH --qos=genomics
##SBATCH --time=4:00:00
##SBATCH --mail-user=james.lingford@monash.edu
##SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
##SBATCH --error=log-%j.err
##SBATCH --output=log-%j.out

module purge

# use local install
# export PATH=$(pwd)/foldseek/bin/:$PATH #cpu version
export PATH=$(pwd)/foldseek-linux-gpu/foldseek/bin/:$PATH #gpu version

# define variables
DATE=$(date +%y%m%d)

# database directories
# DBDIR="/home/jamesl/rp24_scratch/Database/FoldSeek"
# PROSTT5DIR="/home/jamesl/rp24_scratch/Database/FoldSeek/ProstT5"

# WARN: change this each time (input dir)
INPUT=$1

# set file & dir names
name=${INPUT##*/}
name=${name%.*}

mkdir -p ./alignDB/$name ./resultDB/$name ./tmp/$name

# # easy-search workflow
# foldseek easy-search \
#     $INPUT \
#     $INPUT \
#     ./alignDB/${name}_allvsallTMscores_v2.tsv \
#     ./tmp \
#     --alignment-type 1 \
#     --tmscore-threshold 0 \
#     --tmscore-threshold-mode 0 \
#     --exhaustive-search 1 \
#     -e inf \
#     --gpu 1 \
#     --format-output query,target,evalue,pident,alntmscore,u,t,qtmscore,ttmscore,rmsd,prob

###

# foldseek: non-easy workflow
foldseek createdb \
    $INPUT \
    ./queryDB/$name \
    --gpu 1

foldseek search \
    ./queryDB/$name \
    ./queryDB/$name \
    ./alignDB/$name/$name \
    ./tmp/$name \
    -a 1 \
    --alignment-type 1 \
    --tmscore-threshold 0 \
    --tmscore-threshold-mode 0 \
    --exhaustive-search 1 \
    -e inf \
    --gpu 1

foldseek convertalis \
    ./queryDB/$name \
    ./queryDB/$name \
    ./alignDB/$name/$name \
    ./resultDB/$name/${name}_allvsallTMscores.tsv \
    --format-mode 0 \
    --format-output query,target,evalue,pident,alntmscore,u,t,qtmscore,ttmscore,rmsd,prob

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

rm -rf tmp/$name/*
