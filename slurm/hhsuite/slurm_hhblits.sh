#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J hhsuite
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
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# set env
module purge
module load hh-suite/3.3.0
# module load miniforge3
# conda activate /fs04/scratch2/rp24/jamesl2/MMseqs2/rp24_scratch2/jamesl2/miniconda/conda/envs/hhblits

# # run hhblits
# hhblits \
#     -i ./input/fefe_test.faa \
#     -n 1 \
#     -d ./databases/UniRef30_2023_02 \
#     -o ./output/test \
#     -oa3m ./output/test.a3m \
#     -ohhm ./output/test.hhm \
#     -blasttab ./output/test.tsv \
#     -add_cons \
#     -cpu 48

# run hhblits
hhblits \
    -i ./input/fefe_test.faa \
    -n 8 \
    -d ./databases/UniRef30_2023_02 \
    -o ./output/test \
    -oa3m ./output/test.a3m \
    -ohhm ./output/test.hmm \
    -opsi ./output/test.psi \
    -blasttab ./output/test.tsv

# git clone https://github.com/soedinglab/hh-suite.git
# mkdir -p hh-suite/build && cd hh-suite/build
# cmake -DCMAKE_INSTALL_PREFIX=. ..
# make -j 4 && make install
# export PATH="$(pwd)/bin:$(pwd)/scripts:$PATH"
# hhblits -h
