#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J taxonomy
#SBATCH --mem=1067000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --account=rp24
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=72:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# set env
module purge
module load miniforge3
conda activate /home/jamesl/rp24/scratch_nobackup/jamesl/miniconda/conda/envs/mmseqs2

# database to search
DATABASE="GTDB_r226/gtdb226"

# threads to use (keep high)
T=95

for file in ./fastainput/*.faa; do
    fastafile=${file##*/}
    name=${fastafile%.*}

    # step 0: mkdir
    if [[ ! -d ./taxonomy_outfiles/${name} ]]; then
        mkdir -p ./taxonomy_outfiles/${name}
    fi

    # run easy-taxonomy first
    mmseqs easy-taxonomy \
        ./fastainput/${fastafile} \
        ./database/${DATABASE} \
        ./taxonomy_outfiles/${name}/${name}-taxonomy \
        ./tmp \
        --lca-mode 3 \
        --format-mode 4 \
        --threads ${T}

    # step 1: create sequenceDB out of fastas
    mmseqs createdb \
        ./fastainput/${FASTA_INPUT} \
        ./queryDB/${name} \
        --dbtype 1

    # step 2: create taxonomyDB from queryDB
    # NOTE: takes many hours to run
    mmseqs taxonomy \
        ./queryDB/${name} \
        ./database/${DATABASE} \
        ./taxaDB/${name} \
        ./tmp \
        -s 7.5 \
        --threads ${T} \
        --lca-mode 3

    # step 3: output taxonomy reports
    # step 3.1: output taxonomy report of resultDB, krona
    mmseqs taxonomyreport \
        ./database/${DATABASE} \
        ./taxaDB/${name} \
        ./outfiles/${name}/${name}-krona_taxa_report.html \
        --report-mode 1

    # step 3.2: output taxonomy report of resultDB, kraken
    mmseqs taxonomyreport \
        ./database/${DATABASE} \
        ./taxaDB/${name} \
        ./outfiles/${name}/${name}-kraken_taxa_report.txt \
        --report-mode 0

done
# # rm -rf ./tmp/*
