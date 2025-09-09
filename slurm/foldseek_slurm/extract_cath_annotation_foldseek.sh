#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J GPU_FoldSeek
#SBATCH --mem=60000
#SBATCH --time=24:00:00
#SBATCH --gres=gpu:A40:1
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --account=rp24
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

# other SLURM options
# --- #SBATCH --gres=gpu:L40S:1
# --- #SBATCH --partition=gpu
# --- #SBATCH --qos=bdiq

# install gpu foldseek (do once)
# wget https://mmseqs.com/foldseek/foldseek-linux-gpu.tar.gz
# tar xvfz foldseek-linux-gpu.tar.gz --one-top-level

# activate env
module purge
module load miniforge3
conda activate /fs04/scratch2/rp24/jamesl2/MMseqs2/foldseeking/rp24_scratch2/jamesl2/miniconda/conda/envs/bedtools
export PATH=$(pwd)/foldseek-linux-gpu/foldseek/bin/:$PATH

# input dir
# WARN: change this each run:
INPUT='./input/groupBtest'

# define paths to databases
DBDIR="/home/jamesl/rp24_scratch/Database/FoldSeek/GPU_DATABASES"

# databases to query
DB1='CATH50_gpu'

# set file & dir names
name=${INPUT##*/}
name=${name%.*}
jobname=${name}_2_${DB1}

# make output dirs if they don't exist
dirlist=(
    "queryDB/${jobname}"
    "cathhitsDB/${jobname}"
    "outfiles/${jobname}"
    "subset_dir/${jobname}/"
    "afdbhitsDB/${jobname}"
    "tmp/${jobname}"
)
for dir in "${dirlist[@]}"; do
    mkdir -p "$dir"
done

# STEP 1
# create db
foldseek createdb \
    $INPUT \
    ./queryDB/${jobname}/${name} \
    --gpu 1

# search models against CATH50_gpu database
# NOTE: using --cov-mode 1 for target coverage, only want to find full(ish) domains, not fragments of domains
foldseek search \
    ./queryDB/${jobname}/${name} \
    ${DBDIR}/$DB1 \
    ./cathhitsDB/${jobname}/${name} \
    ./tmp/${jobname} \
    -s 9.5 \
    -c 0.2 \
    --cov-mode 1 \
    -e 0.001 \
    -a 1 \
    --gpu 1 \
    --remove-tmp-files

# extract results
foldseek convertalis \
    ./queryDB/${jobname}/${name} \
    ${DBDIR}/$DB1 \
    ./cathhitsDB/${jobname}/${name} \
    ./outfiles/${jobname}/${name}-CATH50_HITS_RAW.tsv \
    --format-mode 0 \
    --format-output query,target,evalue,bits,pident,qstart,qend,qlen,alnlen,qcov,tcov,qtmscore,ttmscore,alntmscore,rmsd,prob,qseq

>&2 echo "convertalis complete"

# filter extracted hits by cath domain presence
tsv="./outfiles/${jobname}/${name}-CATH50_HITS_RAW.tsv"
if [[ $tsv == *fefe* ]]; then
    grep -E "3.40.950.10|3.40.50.1780" $tsv |
        sort -k1,1 -k8,8gr -k3,3g |
        sed 's/_model_0//' |
        sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
fi
if [[ $tsv == *nife* ]]; then
    grep -E "1.10.645.10" $tsv |
        sort -k1,1 -k8,8gr -k3,3g |
        sed 's/_model_0//' |
        sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
fi
if [[ $tsv == *feon* ]]; then
    grep -E "3.40.50.720" $tsv |
        sort -k1,1 -k8,8gr -k3,3g |
        sed 's/_model_0//' |
        sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
else
    grep -E "3.40.950.10|3.40.50.1780|1.10.645.10|3.40.50.720" $tsv |
        sort -k1,1 -k8,8gr -k3,3g |
        sed 's/_model_0//' |
        sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
fi

>&2 echo 'filtering complete'

# make bedfile
posfile=./outfiles/${jobname}/${name}-CATH50_filtered.tsv
awk -vOFS="\t" '{print $1, $6, $7}' $posfile >./outfiles/${jobname}/${name}-bedfile.bed
bedfile=./outfiles/${jobname}/${name}-bedfile.bed

>&2 echo 'made bedfile'

# convert cif files to pdb
mkdir -p ./outfiles/${jobname}/pdbs_full
for cif in ${INPUT}/*.cif; do
    name=${cif##*/}
    name=${name%.*}
    maxit -input $cif -output ${INPUT}/${name}.pdb -o 2
done
mv ${INPUT}/*.pdb ./outfiles/${jobname}/pdbs_full

>&2 echo 'converted cif to pdb'

# output full fasta file
mkdir -p ./outfiles/${jobname}/fastas_full
sort -u -k1,1 $posfile |
    awk '{printf(">%s\n%s\n"), $1, $NF}' |
    splitfaa.sh - ./outfiles/${jobname}/fastas_full

>&2 echo 'output full fasta files'

# extract subseq of fasta file
mkdir -p ./outfiles/${jobname}/fastas_subseqs
for faa in ./outfiles/${jobname}/fastas_full/*.faa; do
    name=${faa##*/}
    name=${name%.*}
    start=$(grep $name $posfile | awk '{print $6}' | head -n 1)
    stop=$(grep $name $posfile | awk '{print $7}' | head -n 1)
    bedtools getfasta \
        -fi $faa \
        -bed <(grep $name $posfile | awk -vOFS="\t" '{print $1, $6, $7}' | head -n 1) \
        -fo ./outfiles/${jobname}/fastas_subseqs/${name}___subseq_${start}-${stop}.faa
done

>&2 echo 'bedtools subseq extraction'

# extract subseq of pdb file
mkdir -p ./outfiles/${jobname}/pdbs_subseqs

while IFS=$'\t' read -r name start stop; do
    fd $name -e pdb --full-path ./outfiles/${jobname}/pdbs_full -x \
        pdb_selres -${start}:${stop} {} >./outfiles/${jobname}/pdbs_subseqs/${name}___subseq_${start}-${stop}.pdb
done <$bedfile

>&2 echo 'pdb_selres extraction'

rm ./outfiles/${jobname}/fastas_full/*.fai
rm -rf tmp/${jobname}
