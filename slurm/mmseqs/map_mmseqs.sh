#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J mmseqs_map
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
conda activate /home/jamesl/rp24/scratch_nobackup/jamesl/miniconda/conda/envs/mmseqs2

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "Usage: $0 [INPUT]"
    exit 1
fi

# NOTE: provide path to fasta to map
input1=$1
# NOTE: provide path to fasta to be database
input2=$2

INPUT=$input1
name=${INPUT##*/}
name=${name%.*}

name2=${input2##*/}
name2=${name%.*}

# Main:

mkdir -p queryDB alignDB filterDB output/mapping/${name}

# make database to map against first
mmseqs createdb \
    $input2 \
    ./database/mapping/$name2 \
    --dbtype 1

DATABASE=./database/mapping/$name2
dbname=${DATABASE##*/}
dbname=${DATABASE%.*}

# run mapping
mmseqs createdb \
    $INPUT \
    ./queryDB/$name \
    --dbtype 1

minIDs=(
    # "0.70"
    # "0.80"
    "0.90"
)

for N in "${minIDs[@]}"; do

    # set names
    suffix=mapseqid${N##*.}
    loopname=${name}_${suffix}

    mmseqs map \
        ./queryDB/$name \
        $DATABASE \
        ./alignDB/$loopname \
        ./tmp/ \
        -s 7.5 \
        -a 1 \
        --threads 95 \
        --min-seq-id ${N}

    mmseqs filterdb \
        ./alignDB/$loopname \
        ./filterDB/$loopname \
        --extract-lines 1

    mmseqs convertalis \
        ./queryDB/$name \
        $DATABASE \
        ./filterDB/$loopname \
        ./output/mapping/${name}/${loopname}_mapped.tsv \
        --format-mode 4 \
        --format-output query,target,pident,bits,evalue,qcov,tcov,qseq,tseq

    table=./output/mapping/${name}/${loopname}_mapped.tsv
    outdir=./output/mapping/${name}

    # output fasta file
    awk -F"\t" 'NR>1{printf ">%s\n%s\n", $1, $(NF-1)}' $table >${table/.tsv/_qseqs.faa}

    # find target IDs that were not mapped in query
    grep -v -f <(awk -F"\t" 'NR>1{print $2}' $table | sort -u) <(faa2tsv.sh $input2) |
        cut -f1 >$outdir/missing_IDs_${suffix}.txt

done

echo "done!"
