#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J mmseqs_search
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
module load miniforge3
conda activate /home/jamesl/rp24/scratch_nobackup/jamesl/miniconda/conda/envs/mmseqs2

mmseqs easy-search \
    ./fastainput/old/feonly_test.faa \
    ./database/GTDB226_genomeIDs/gtdb226 \
    ./search_outfiles/quick_test.tsv \
    ./tmp \
    -s 4 \
    --threads 95 \
    --format-mode 4 \
    --format-output query,target,evalue,pident,taxid,taxname,taxlineage,tseq
