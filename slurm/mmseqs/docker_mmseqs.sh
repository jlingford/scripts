#!/bin/bash
#SBATCH -D ./
#SBATCH -J docker_mmseqs
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --account=rp24
#SBATCH --partition=bdi
#SBATCH --qos=bdiq
#SBATCH --gres=gpu:A40:1
#SBATCH --mem=900000
#SBATCH --time=1:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# set env
# module purge
# module load singularity/latest
# module load miniforge3
# conda activate /home/jamesl/rp24/scratch_nobackup/jamesl/miniconda/conda/envs/mmseqs2

CACHE="/home/jamesl/rp24_scratch2/jamesl2/cache"
SIF="/home/jamesl/rp24_scratch2/jamesl2/docker_mmseqs/mmseqs2_master-cuda12.sif"
# DIR="/home/jamesl/rp24_scratch2/jamesl2/MMseqs2"

# make GPU DB from CPU DB
singularity run --nv \
    -B $CACHE:/cache \
    -B $(pwd):/work \
    $SIF makepaddedseqdb \
    /work/database/HydDB1/all-in-one/hydDB1 \
    /work/database/HydDB1/all-in-one/hydDB1_pad

#start GPU server
# singularity run --nv \
#     -B $CACHE:/cache \
#     -B $(pwd):/work \
#     $SIF gpuserver \
#     /work/database/ColabFoldDB_GPU/colabfold_envdb_202108_db --max-seqs 10000 --db-load-mode 0 --prefilter-mode 1 &
# PID1=$!

# start GPU server
singularity run --nv \
    -B $CACHE:/cache \
    -B $(pwd):/work \
    $SIF gpuserver \
    /work/database/HydDB1/all-in-one/hydDB1_pad --max-seqs 10000 --db-load-mode 1 --prefilter-mode 1 &
PID1=$!

sleep 120

# run mmseqs
singularity run --nv \
    -B $CACHE:/cache \
    -B $(pwd):/work \
    $SIF easy-search \
    /work/NuoD_Hod1.fasta \
    /work/database/HydDB1/all-in-one/hydDB1_pad \
    /work/output_NuoD2.m8 \
    /work/tmp \
    --gpu 1 \
    --gpu-server 1 \
    --remove-tmp-files 1

# inputs and output

# createdb
# mmseqs createdb \
#     ./database/HydDB1/NiFe/NiFe_hydrogenase_reformated.fasta \
#     ./database/HydDB1/NiFe/nife_hydDB
#
# mmseqs createdb \
#     ./database/HydDB1/FeFe/FeFe_hydrogenase_reformated.fasta \
#     ./database/HydDB1/FeFe/fefe_hydDB
#
# mmseqs createdb \
#     ./database/HydDB1/Fe/Fe_hydrogenase.fasta \
#     ./database/HydDB1/Fe/fe_hydDB
#
# mmseqs createdb \
#     ./database/HydDB1/all-in-one/Fe_hydrogenase.fasta \
#     ./database/HydDB1/all-in-one/FeFe_hydrogenase_reformated.fasta \
#     ./database/HydDB1/all-in-one/NiFe_hydrogenase_reformated.fasta \
#     ./database/HydDB1/all-in-one/hydDB1

# easy search
# mmseqs easy-search \
#     ./input/$INPUT \
#     ./database/GTDB_db/gtdb \
#     ./output/$OUTPUT \
#     ./tmp \
#     -s 7.5 \
#     --remove-tmp-files
#
# search
# mmseqs search \
#     ./database/HydDB1/NiFe/nife_hydDB \
#     ./database/NCBI_NR_db/ncbi_nr \
#     ./resultDB/NiFe/nifeDB \
#     ./tmp \
#     -s 7.5 \
#     --exhaustive-search \
#     --remove-tmp-files
