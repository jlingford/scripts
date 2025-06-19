#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J interproscan
#SBATCH --mem=367000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --account=rp24
#SBATCH --partition=genomicsb
#SBATCH --qos=genomicsbq
#SBATCH --time=48:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

# # get data and install (do once)
# curl -O http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.73-104.0/alt/interproscan-data-5.73-104.0.tar.gz
# curl -O http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.73-104.0/alt/interproscan-data-5.73-104.0.tar.gz.md5
# md5sum -c interproscan-data-5.73-104.0.tar.gz.md5
# tar -pxzf interproscan-data-5.73-104.0.tar.gz
# mkir input temp output
# wget -O input/e-coli.fa 'https://rest.uniprot.org/uniprotkb/stream?format=fasta&query=%28proteome%3AUP000000625%29'
# singularity pull docker://interpro/interproscan:latest

# input
INPUTFASTA='./input/id70/nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-clust_representatives-37373_seqs.faa'
inputfile=${INPUTFASTA/.\/input\//}

# set outdir name
name=${inputfile##*/}
name=${name%%_*}
outsubdir=${name}
if [[ ! -d ./output/${outsubdir} ]]; then
    mkdir -p ./output/${outsubdir}
fi

# inputfile="e-coli.fa"

# module load miniforge3
# cd ./interproscan-5.73-104.0
# python3 setup.py -f interproscan.properties
# cd ..

# run container
singularity exec \
    -B $PWD/interproscan-5.73-104.0/data:/opt/interproscan/data \
    -B $PWD/input:/input \
    -B $PWD/temp:/temp \
    -B $PWD/output:/output \
    interproscan_5.73-104.0.sif \
    /opt/interproscan/interproscan.sh \
    --input /input/${inputfile} \
    --disable-precalc \
    --output-dir /output/${outsubdir} \
    --tempdir /temp \
    --cpu 8

#--appl CDD,Pfam
