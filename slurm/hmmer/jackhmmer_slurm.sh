#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J hmmer
#SBATCH --mem=367000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
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

# vars
FASTA="nife-1.faa"
NAME=NiFe

# database to query
DBDIR="/home/jamesl/rp24_scratch/Database/Diamond/GTDB_r226"

# search profile against a database
jackhmmer \
    -o ./output_jackhmmer/${NAME}-jackhmmer.out \
    -A ./output_jackhmmer/${NAME}-jackhmmer.aln \
    --tblout ./output_jackhmmer/${NAME}-jackhmmer-tblout.tsv \
    --domtblout ./output_jackhmmer/${NAME}-jackhmmer-domtblout.tsv \
    --chkhmm ./output_jackhmmer/${NAME} \
    --chkali ./output_jackhmmer/${NAME} \
    --acc \
    -E 0.001 \
    --incE 0.001 \
    ./input_fasta/${FASTA} \
    $DBDIR/gtdb_r226_combined.faa

# # create index for esl-sfetch. Do once.
# zcat $DBDIR/gtdb_r226_combined.gz | sed 's/ # .*$//g' | sed 's/*//' >$DBDIR/gtdb_r226_combined.faa
# esl-sfetch --index $DBDIR/gtdb_r226_combined.faa

# retrieve seqs with esl-sfetch
grep -v "^#" ./output_jackhmmer/${NAME}-jackhmmer-tblout.tsv |
    awk '{print $1}' |
    esl-sfetch -f $DBDIR/gtdb_r226_combined.faa - >./output_jackhmmer/${NAME}-jackhmmer_hits.faa

# retrieve subseqs with esl-sfetch
grep -v "^#" ./output_jackhmmer/${NAME}-jackhmmer-domtblout.tsv |
    awk '{print $1"/"$20"-"$21, $20, $21, $1}' |
    esl-sfetch -Cf $DBDIR/gtdb_r226_combined.faa - >./output_jackhmmer/${NAME}-jackhmmer_hits-subseqs.faa

##
