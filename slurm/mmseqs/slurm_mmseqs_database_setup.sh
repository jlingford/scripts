#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J mmseqs_dbsetup
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

# mmseqs --help
# mmseqs search --help

# inputs and output
# rm -rf ./database/UniRef90_db
#
# set database to download
# DBNAME="UniRef90"
# dbname=${DBNAME,,}
#
# download database
# mkdir -p ./database/${DBNAME}
# mmseqs databases \
#     ${DBNAME} \
#     ./database/${DBNAME}/${dbname} \
#     ./tmp \
#     --remove-tmp-files 1 \
#     --threads 95 \
#     -v 3

DBDIR=/home/jamesl/rp24_scratch/Database/GlobDB_r226
# # make GlobDB_r226 mmseqs database
# FASTA=/home/jamesl/rp24_scratch/Database/GlobDB_r226/globdb_r226_protein_fasta_DB.faa.gz
# mmseqs createdb \
#     $FASTA \
#     ${DBDIR}/mmseqsDB/globdb_r226_protein_fasta_DB \
#     --dbtype 1 \
#     --write-lookup 1 \
#     --compressed 1

# add taxonomy info to GlobDB_r226 database
DATABASE=/home/jamesl/rp24_scratch/Database/GlobDB_r226/mmseqsDB/globdb_r226_protein_fasta_DB
TAXMAPDIR=/home/jamesl/rp24_scratch/Database/GlobDB_r226/taxdump
NCBITAXDIR=/home/jamesl/rp24_scratch/Database/GlobDB_r226/ncbi-taxdump
mmseqs createtaxdb \
    $DATABASE \
    ./tmp \
    --ncbi-tax-dump ${NCBITAXDIR}/ \
    --tax-mapping-file ${TAXMAPDIR}/taxidmap \
    --tax-mapping-mode 1 \
    -v 3 \
    --threads 95

# # MAKE GTDB taxonomy database with genomeIDs this time
# FASTA=/home/jamesl/rp24_scratch/Database/Diamond/GTDB_r226/gtdb226_combined_faa_withgenomeids.faa.gz
# mmseqs createdb \
#     $FASTA \
#     ./database/GTDB226_genomeIDs/gtdb226 \
#     --dbtype 1
#
# TAXDIR=/home/jamesl/rp24_scratch/Database/Diamond/GTDB_r226/old2/gtdb-taxdump-R226
# mmseqs createtaxdb \
#     ./database/GTDB226_genomeIDs/gtdb226 \
#     ./tmp \
#     --ncbi-tax-dump $TAXDIR \
#     --tax-mapping-file $TAXDIR/taxidmap \
#     --threads 95
#
# createdb
# mmseqs createdb \
#     ./database/HydDB1/NiFe/NiFe_hydrogenase_reformated.fasta \
#     ./database/HydDB1/NiFe/nife_hydDB

# mmseqs createdb \
#     ./database/HydDB1/FeFe/FeFe_hydrogenase_reformated.fasta \
#     ./database/HydDB1/FeFe/fefe_hydDB
#
# mmseqs createdb \
#     ./database/HydDB1/Fe/Fe_hydrogenase.fasta \
#     ./database/HydDB1/Fe/fe_hydDB
#
# mmseqs createdb \
#     ./database/HydDB1/all-in-one/Fe_hydrogenase.fasta \
#     ./database/HydDB1/all-in-one/FeFe_hydrogenase_reformated.fasta \
#     ./database/HydDB1/all-in-one/NiFe_hydrogenase_reformated.fasta \
#     ./database/HydDB1/all-in-one/hydDB1

# # easy search
# mmseqs easy-search \
#     ./database/HydDB1/Fe/Fe_hydrogenase.fasta \
#     ./database/GTDB_db/gtdb \
#     ./Fe_gtdb.m8 \
#     ./tmp \
#     -s 7.5 \
#     --remove-tmp-files 1

# # search
# mmseqs search \
#     ./database/HydDB1/NiFe/nife_hydDB \
#     ./database/GTDB_db/gtdb \
#     ./resultDB/NiFe/nife_gtdb \
#     ./tmp \
#     -s 7.5 \
#     -a 1 \
#     --remove-tmp-files 1

# DB=NiFe
# db=nife

# # search
# mmseqs search \
#     ./database/HydDB1/${DB}/${db}_hydDB \
#     ./database/GTDB_db/gtdb \
#     ./resultDB/${DB}/${db}_gtdb \
#     ./tmp \
#     -s 7.5 \
#     -a 1 \
#     --remove-tmp-files 1

# # convertalis
# mmseqs convertalis \
#     ./database/HydDB1/${DB}/${db}_hydDB \
#     ./database/GTDB_db/gtdb \
#     ./resultDB/${DB}/${db}_gtdb \
#     ./convertalis_out/${DB}/${db}_gtdb.tsv \
#     --format-mode 4 \
#     --format-output query,target,evalue,gapopen,pident,nident,qcov,tcov,raw,bits,taxid,taxname,taxlineage,tseq

# map
# mmseqs map \
#     ./database/HydDB1/${DB}/${db}_hydDB \
#     ./database/GTDB_db/gtdb \
#     ./resultDB/${DB}/${db}_gtdb_map \
#     ./tmp \
#     -a 1
#
# # convertalis
# mmseqs convertalis \
#     ./database/HydDB1/${DB}/${db}_hydDB \
#     ./database/GTDB_db/gtdb \
#     ./resultDB/${DB}/${db}_gtdb_map \
#     ./convertalis_out/${DB}/${db}_gtdb_map.tsv \
#     --format-mode 4 \
#     --format-output query,target,evalue,gapopen,pident,nident,qcov,tcov,raw,bits,taxid,taxname,taxlineage,tseq
