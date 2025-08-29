#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J FoldSeek
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
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

##SBATCH -D ./
##SBATCH -J Foldseek_clustering
##SBATCH --mem=40000
##SBATCH --time=4:00:00
##SBATCH --gres=gpu:L40S:1
##SBATCH --partition=gpu
##SBATCH --nodes=1
##SBATCH --ntasks-per-node=1
##SBATCH --cpus-per-task=12
##SBATCH --account=rp24
##SBATCH --mail-user=james.lingford@monash.edu
##SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
##SBATCH --error=log-%j.err
##SBATCH --output=log-%j.out

# other SLURM options
# --- #SBATCH --gres=gpu:L40S:1
# --- #SBATCH --partition=gpu
# --- #SBATCH --qos=bdiq

# install gpu foldseek (do once)
# wget https://mmseqs.com/foldseek/foldseek-linux-gpu.tar.gz
# tar xvfz foldseek-linux-gpu.tar.gz --one-top-level

# activate env
module purge
export PATH=$(pwd)/foldseek-linux-gpu/foldseek/bin/:$PATH

# set job name
# WARN: change this each run:
INPUT='./input/fefe_boltz_covm00_id80_cifs'

name=${INPUT##*/}
name=${name%.*}

# make output dirs if they don't exist
dirlist=(
    "queryDB"
    "outfiles"
    "clusterDB"
    "alignDB"
    "tmp/${name}"
    "resultDB/${name}/SuperposedPDBs_${name}"
    "resultDB/${name}/ClusterrepPDBs_${name}"
)
for dir in "${dirlist[@]}"; do
    mkdir -p "$dir"
done

# STEP 1
# create input db from cif files
foldseek createdb \
    $INPUT \
    ./queryDB/${name} \
    --gpu 1

# STEP 2
# clustering
foldseek cluster \
    ./queryDB/${name} \
    ./clusterDB/${name} \
    ./tmp/${name} \
    -a 1 \
    -s 7.5 \
    -c 0.8 \
    -e 0.001 \
    --cov-mode 0 \
    --cluster-mode 0

# STEP 2.1
# output tsv of all clusters
foldseek createtsv \
    ./queryDB/${name} \
    ./clusterDB/${name} \
    ./resultDB/${name}/${name}_clusterslistRAW.tsv

table="./resultDB/${name}/${name}_clusterslistRAW.tsv"
newtable=./resultDB/${name}/${name}_clusterslist.tsv
# count out size of cluster reps
cut -f1 $table | uniq -c | sort -k1,1gr | sed 's/_model_0//' | awk -vOFS="\t" '{print $2, $1}' >$newtable
touch ./resultDB/${name}/$(wc -l $newtable | cut -f1 -d" ")_total_clusters.txt

# STEP 3
# create alignDB
foldseek align \
    ./queryDB/$name \
    ./queryDB/$name \
    ./clusterDB/$name \
    ./alignDB/$name \
    -a 1

# STEP 4
# output results in tsv
foldseek convertalis \
    ./queryDB/$name \
    ./queryDB/$name \
    ./alignDB/$name \
    ./resultDB/${name}/${name}_clusters.tsv \
    --format-mode 0 \
    --format-output query,target,evalue,pident,alntmscore,u,t,qtmscore,ttmscore,rmsd,lddt,prob,qcov,tcov,qseq,tseq

# output results in html
foldseek convertalis \
    ./queryDB/$name \
    ./queryDB/$name \
    ./alignDB//$name \
    ./resultDB/${name}/${name}_clusters.html \
    --format-mode 3

# output results in pdb superposition
foldseek convertalis \
    ./queryDB/$name \
    ./queryDB/$name \
    ./alignDB/$name \
    ./resultDB/${name}/SuperposedPDBs_${name}/${name}.pdb \
    --format-mode 5

# STEP 5
# output PDB files of clust reps (2 step)
foldseek createsubdb \
    ./clusterDB/$name \
    ./queryDB/$name \
    ./clusterDB/${name}_CLUSTREPS

foldseek convert2pdb \
    ./clusterDB/${name}_CLUSTREPS \
    ./resultDB/${name}/ClusterrepPDBs_${name}/${name}_all_pdbs.pdb

# cp original cif files over if they are cluster reps
while IFS=$'\t' read -r model num; do
    fd $model -e cif --full-path $INPUT -x cp {} ./resultDB/${name}/ClusterrepPDBs_${name}/
done <$newtable

rm -rf tmp/${name}/*

# --format-output STR   Choose comma separated list of output columns from:
#                        query,target,evalue,gapopen,pident,fident,nident,qstart,qend,qlen
#                        tstart,tend,tlen,alnlen,raw,bits,cigar,qseq,tseq,qheader,theader,qaln,taln,mismatch,qcov,tcov
#                        qset,qsetid,tset,tsetid,taxid,taxname,taxlineage,
#                        lddt,lddtfull,qca,tca,t,u,qtmscore,ttmscore,alntmscore,rmsd,prob
#                        complexqtmscore,complexttmscore,complexu,complext,complexassignid
#                         [query,target,fident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits]

# search prostt5-models against CATH50_gpu database
# foldseek search \
#     ./queryDB/${jobname}/${name} \
#     ${DBDIR}/$DB1 \
#     ./clusterDB/${jobname}/${name} \
#     ./tmp \
#     -s 9.5 \
#     -a 1 \
#     --gpu 1 \
#     --remove-tmp-files

# extract results
# foldseek convertalis \
#     ./queryDB/${jobname}/${name} \
#     ./clusterDB/${jobname}/${name} \
#     ./clusterDB/${jobname}/${name} \
#     ./outfiles/${jobname}/${name}-foldseek_clusters.tsv \
#     --format-mode 0

# filter extracted hits by cath domain presence
# tsv="./outfiles/${jobname}/${name}-CATH50_HITS_RAW.tsv"
# if [[ $tsv == *fefe* ]]; then
#     grep -E "3.40.950.10|3.40.50.1780" $tsv | sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
# fi
# if [[ $tsv == *nife* ]]; then
#     grep -E "1.10.645.10" $tsv | sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
# fi
# if [[ $tsv == *feon* ]]; then
#     grep -E "3.40.50.720" $tsv | sort -u -k1,1 >${tsv/CATH50_HITS_RAW.tsv/CATH50_filtered.tsv}
# fi
#
# # make log file
# echo -e "# ${name}" >>./outfiles/${jobname}/count.txt
# echo -e $(grep -c "^>" $INPUT) ${INPUT} >>./outfiles/${jobname}/count.txt
# wc -l ./outfiles/${jobname}/${name}-CATH50_filtered.tsv >>./outfiles/${jobname}/count.txt
#
# # make subset list file to grep first foldseek queryDB with:
# # NOTE: make sure to select 1st field containing queryDB ID's
# cut -f1 ./outfiles/$jobname/${name}-CATH50_filtered.tsv >./subset_dir/${jobname}/${name}-CATH50_subset_list.txt
# # NOTE: the prostt5-model queryDB does not contain Ca info since it only generates 3Di+aa sequences
# grep -f ./subset_dir/${jobname}/${name}-CATH50_subset_list.txt ./queryDB/${jobname}/${name}.lookup >./subset_dir/${jobname}/${name}-CATH50_subsetDB.tsv
#
# # createsubdb of queryDB prostt5-models
# foldseek createsubdb \
#     ./subset_dir/${jobname}/${name}-CATH50_subsetDB.tsv \
#     ./queryDB/${jobname}/$name \
#     ./queryDB/${jobname}/${name}-subset
#
# # copy input fasta and subset list to outfile dir
# cp $INPUT ./outfiles/${jobname}
# cp ./subset_dir/${jobname}/${name}-CATH50_subset_list.txt ./outfiles/${jobname}

echo "Finished foldseek for ${INPUT}"

# rm -rf tmp/*
