#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J batch_slurm
#SBATCH --mem=1000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --account=rp24
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=1:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# for file in ./input_fasta/new_queries/*.faa; do
for file in ./profiles/*.hmm; do
    name=${file##*/}
    name=${name%%_*}

    # launch SBATCH
    sbatch -J ${name}_hmmer slurm_hmmer.sh ${file}

done
