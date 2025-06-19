#!/bin/bash
#SBATCH -D ./
#SBATCH -J MSAs
#SBATCH --account=rp24
#SBATCH --time=4:00:00
#SBATCH --qos=genomics
#SBATCH --partition=genomics
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=40000
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

INPUT=./fastainput/gtdb226_clustreps/feon_splitfasta2
name=${INPUT##*/}

if [[ ! -d ./msa_output/${name} ]]; then
    mkdir -p ./msa_output/${name}
fi

module purge
# export PATH="/home/jamesl/rp24/scratch_nobackup/jamesl/localcolabfold/colabfold-conda/bin:$PATH"
# module load gcc/10.2.0
export PATH="/home/jamesl/rp24/scratch_nobackup/jamesl/local-new/localcolabfold/colabfold-conda/bin:$PATH" # updated localcolabfold-v1.5.5
export LD_LIBRARY_PATH="/home/jamesl/rp24/scratch_nobackup/jamesl/local-new/localcolabfold/colabfold-conda/lib:${LD_LIBRARY_PATH}"

##log
#echo "slurm_MSA.sh"
#cat slurm_MSA.sh
#colabfold_batch --help >colabfold_batch_help.txt

colabfold_batch \
    --msa-only \
    $INPUT \
    ./msa_output/${name}
