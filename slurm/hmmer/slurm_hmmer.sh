#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J hmmer
#SBATCH --mem=100000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --account=rp24
#SBATCH --partition=genomicsb
#SBATCH --qos=genomicsbq
#SBATCH --time=24:00:00
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
jobname=${name}_${dbname}_redo

if [[ ! -d ./outputs/${jobname} ]]; then
    mkdir -p ./outputs/${jobname}
fi

# # PHMMER
# # search profile against a database
# phmmer \
#     -o ./outputs/${jobname}/${name}-PHMMER.out \
#     -A ./outputs/${jobname}/${name}-PHMMER.aln \
#     --tblout ./outputs/${jobname}/${name}-PHMMER-tblout.tsv \
#     --domtblout ./outputs/${jobname}/${name}-PHMMER-domtblout.tsv \
#     --pfamtblout ./outputs/${jobname}/${name}-PHMMER-pfamtblout.pfam \
#     --acc \
#     -E 0.001 \
#     --incE 0.001 \
#     $FASTA \
#     $DATABASE
#
# # retrieve seqs with esl-sfetch
# grep -v "^#" ./outputs/${jobname}/${name}-PHMMER-tblout.tsv |
#     awk '{print $1}' |
#     esl-sfetch -f $DATABASE - >./outputs/${jobname}/${name}-hits_PHMMER.faa
#
# # retrieve subseqs with esl-sfetch
# grep -v "^#" ./outputs/${jobname}/${name}-PHMMER-domtblout.tsv |
#     awk '{print $1"/"$20"-"$21, $20, $21, $1}' |
#     esl-sfetch -Cf $DATABASE - >./outputs/${jobname}/${name}-hits_PHMMER-subseqs.faa

# HMMERSEARCH
# search profile against a database
hmmsearch \
    -o ./outputs/${jobname}/${name}-HMMER.out \
    -A ./outputs/${jobname}/${name}-HMMER.aln \
    --tblout ./outputs/${jobname}/${name}-HMMER-tblout.tsv \
    --domtblout ./outputs/${jobname}/${name}-HMMER-domtblout.tsv \
    --pfamtblout ./outputs/${jobname}/${name}-HMMER-pfamtblout.pfam \
    --acc \
    --noali \
    -E 10.0 \
    $PROFILE \
    $DATABASE

# retrieve seqs with esl-sfetch
grep -v "^#" ./outputs/${jobname}/${name}-HMMER-tblout.tsv |
    awk '{print $1}' |
    esl-sfetch -f $DATABASE - >./outputs/${jobname}/${name}-hits_HMMER.faa

# retrieve subseqs with esl-sfetch
grep -v "^#" ./outputs/${jobname}/${name}-HMMER-domtblout.tsv |
    awk '{print $1"/"$20"-"$21, $20, $21, $1}' |
    esl-sfetch -Cf $DATABASE - >./outputs/${jobname}/${name}-hits_HMMER-subseqs.faa

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
