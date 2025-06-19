#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J mafft
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

module purge
module load miniforge3
conda activate /fs04/scratch2/rp24/jamesl2/MMseqs2/mafft_dir/rp24_scratch2/jamesl2/miniconda/conda/envs/mafft

INPUT="./input/nife_hyddb1-cov80-id90-covm0-clustm0-clust_representatives-1491_seqs.faa"
OUTPUT_NAME=nife_hyddb1-cluster_cov80id90

DATE=$(date +%y%m%d)

##FFT-NS-i method (max iterations = 2)
#fftnsi \
#    --reorder \
#    --thread -1 \
#    ${INPUT} >mafft_output/${INPUT%.*}-fftnsi-${DATE}.afa

#L-INS-i method (max iterations = 1000)
linsi \
    --reorder \
    --thread -1 \
    ${INPUT} >./output/${OUTPUT_NAME}-linsi_aln-${DATE}.afa

# # NW-NS-PartTree-1 (fast rough tree for ~10-50k sequences)
# mafft \
#     --retree 1 \
#     --maxiterate 0 \
#     --nofft \
#     --parttree \
#     --reorder \
#     --thread -1 \
#     ${INPUT} >mafft_output/${INPUT%.*}-parttree-${DATE}.afa
