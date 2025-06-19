#!/bin/bash
#SBATCH -D ./
#SBATCH -J gpu_colabfoldsearch
#SBATCH --account=rp24
#SBATCH --time=4:00:00
#SBATCH --mem=200000
#SBATCH --gres=gpu:A100:1
#SBATCH --partition=bdi
#SBATCH --qos=bdiq
#SBATCH --cpus-per-task=12
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# #SBATCH --partition=bdi
# #SBATCH --qos=bdiq
# #SBATCH --gres=gpu:A40:1
# #SBATCH --partition=genomics
# #SBATCH --qos=genomics

# set environment
module purge
# module load singularity/latest
# module load mmseqs2
export PATH="/home/jamesl/rp24/scratch_nobackup/jamesl/local-new/localcolabfold/colabfold-conda/bin:$PATH" # updated localcolabfold-v1.5.5
export LD_LIBRARY_PATH="/home/jamesl/rp24/scratch_nobackup/jamesl/local-new/localcolabfold/colabfold-conda/lib:${LD_LIBRARY_PATH}"

# module load miniforge3
# conda activate /home/jamesl/rp24/scratch_nobackup/jamesl/localcolabfold/colabfold-conda
# conda activate /fs04/scratch2/rp24/jamesl2/GPU_mmseqs2/rp24_scratch2/jamesl2/miniconda/conda/envs/nvcc

# mmseqs binary
# CPU_MMSEQS=/home/jamesl/rp24/scratch_nobackup/jamesl/miniconda/conda/envs/mmseqs2/bin/mmseqs
# GPU_MMSEQS=/home/jamesl/rp24_scratch2/jamesl2/GPU_mmseqs2/build/bin/mmseqs
GPU_MMSEQS=/home/jamesl/rp24_scratch2/jamesl2/GPU2_mmseqs2/mmseqs/bin/mmseqs
# CPU_DB_DIR=/home/jamesl/rp24_scratch/rp24/jamesl2/MMseqs2/mmseqs2_dir/database/ColabFoldDB
GPU_DB_DIR=/home/jamesl/rp24_scratch/rp24/jamesl2/MMseqs2/mmseqs2_dir/database/ColabFoldDB_GPU
# DOCKER_MMSEQS=$(singularity run -B /home/jamesl/rp24_scratch2/jamesl2/cache /home/jamesl/rp24_scratch2/jamesl2/docker_mmseqs/mmseqs2_master-cuda12.sif)

#log
colabfold_search --help >colabfold_search_help.txt
colabfold_batch --help >colabfold_batch_help.txt

# # start GPU server
export CUDA_VISIBLE_DEVICES=0,1
$GPU_MMSEQS gpuserver ${GPU_DB_DIR}/colabfold_envdb_202108_db --max-seqs 10000 --db-load-mode 2 --prefilter-mode 1 &
PID1=$!
$GPU_MMSEQS gpuserver ${GPU_DB_DIR}/uniref30_2302_db --max-seqs 10000 --db-load-mode 2 --prefilter-mode 1 &
PID2=$!

# run MSA with GPU
CUDA_VISIBLE_DEVICES=0,1 colabfold_search \
    --mmseqs $GPU_MMSEQS \
    --gpu 1 \
    --gpu-server 1 \
    ./test.csv \
    $GPU_DB_DIR \
    ./msa_output/test2

kill $PID1
kill $PID2

# --gpu-server 1 \

# # run MSA with CPU, attempt 1
# MMSEQS_IGNORE_INDEX=1 colabfold_search \
#     ./fastainput/new_queries/cluster_reps \
#     $CPU_DB_DIR \
#     ./msa_output/

# # run MSA with CPU
# colabfold_search \
#     --mmseqs $CPU_MMSEQS \
#     ./fastainput/gtdb226_clustreps/ \
#     $CPU_DB_DIR \
#     ./msa_output/

# # run MSA with GPU
# colabfold_search \
#     --mmseqs $GPU_MMSEQS \
#     --gpu 1 \
#     --gpu-server 1 \
#     ./test.faa \
#     $GPU_DB_DIR \
#     ./msa_output/gpu_test/

# run AF2
# colabfold_batch \
#     --model-type=alphafold2_multimer_v3 \
#     --num-recycle=20 \
#     --recycle-early-stop-tolerance=0.0 \
#     --amber \
#     --use-gpu-relax \
#     --num-relax=1 \
#     --zip \
#     input_msa/$MSA_OUTPUT_DIR \
#     output/$AF2_OUTPUT_DIR
