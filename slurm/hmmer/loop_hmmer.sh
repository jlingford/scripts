#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J loop_hmmer
#SBATCH --mem=100000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --account=rp24
#SBATCH --partition=genomicsb
#SBATCH --qos=genomicsbq
#SBATCH --time=72:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# set env
module purge
module load miniforge3
conda activate /fs04/scratch2/rp24/jamesl2/MMseqs2/rp24_scratch2/jamesl2/miniconda/conda/envs/hmmer

# database to query
DATABASE='/home/jamesl/rp24_scratch/Database/GlobDB_r226/globdb_r226_protein_fasta_DB.faa'
dbdir=${DATABASE%/*}
dbname=${DATABASE##*/}
dbname=${dbname%%_*}

# # fasta input
# FASTA=$1
# name=${FASTA##*/}
# name=${name%%.*}
# jobname=${name}_${dbname}

# profile input
PROFILE=$1
name=${PROFILE##*/}
name=${name%%.*}
name=${name,,}
jobname=${name}_globdb226_allgenomes

if [[ ! -d ./outputs/${jobname} ]]; then
    mkdir -p ./outputs/${jobname}
fi

ALL_GENOMES=/home/jamesl/rp24_scratch/Database/GlobDB_r226/globdb_r226_protein_fasta

for genome in ${ALL_GENOMES}/*/*.faa.gz; do

    # set var
    name=${genome##*/}
    name=${name%%.*}

    # HMMERSEARCH
    # search profile against a database
    hmmsearch \
        --tblout ./outputs/${jobname}/${name}-HMMER-tblout.tsv \
        --domtblout ./outputs/${jobname}/${name}-HMMER-domtblout.tsv \
        --acc \
        --noali \
        -E 10.0 \
        $PROFILE \
        $genome

    # retrieve seqs with esl-sfetch
    grep -v "^#" ./outputs/${jobname}/${name}-HMMER-tblout.tsv |
        awk '{print $1}' |
        esl-sfetch -f $DATABASE - >./outputs/${jobname}/${name}-hits_HMMER.faa

    # # retrieve subseqs with esl-sfetch
    # grep -v "^#" ./outputs/${jobname}/${name}-HMMER-domtblout.tsv |
    #     awk '{print $1"/"$20"-"$21, $20, $21, $1}' |
    #     esl-sfetch -Cf $DATABASE - >./outputs/${jobname}/${name}-hits_HMMER-subseqs.faa

done

cat ./outputs/${jobname}/*.faa >./outputs/${jobname}/combined.faa

##

# create index for esl-sfetch. Do once.
# zcat $DATABASE | sed 's/ # .*$//g' | sed 's/*//' >${dbdir}/gtdb226_combined_faa_withgenomeids_for_HMMER.faa
# echo "md5sum check pre-decompression:"
# md5sum $DATABASE
# gzip -d $DATABASE
# esl-sfetch --index ${DATABASE%.*}
# gzip ${DATABASE%.*}
# echo "md5sum check post-recompression"
# md5sum $DATABASE
