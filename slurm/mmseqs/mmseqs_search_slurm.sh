#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J mmseqs_search
#SBATCH --mem=1267000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
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
conda activate /home/jamesl/rp24/scratch_nobackup/jamesl/miniconda/conda/envs/mmseqs2

# database to search
DATABASE='/home/jamesl/rp24_scratch/Database/GlobDB_r226/mmseqsDB/globdb_r226_protein_fasta_DB'
dbname=${DATABASE##*/}
dbname=${dbname%%_*}

# threads to use (keep high)
T=95

# set input file
FASTA_INPUT=$1
name=${FASTA_INPUT##*/}
name=${name%.*}
resultname=${name}-targetdb_${dbname}

# mkdirs
if [[ ! -d ./search_outfiles/${resultname} ]]; then
    mkdir -p ./search_outfiles/${resultname}
fi
directories=("queryDB" "resultDB")
for dir in "${directories[@]}"; do
    if [[ ! -d ${dir} ]]; then
        mkdir -p ${dir}
    fi
done

# step 1: create sequenceDB out of fastas
mmseqs createdb \
    ${FASTA_INPUT} \
    ./queryDB/${name} \
    --dbtype 1

# step 2: search
# NOTE: --cov-mode 2 = coverage of query sequence, set to 80% (to avoid returning small fragments)
# NOTE: --num-iterations 2 = PSI-BLAST style search, generates a profile for more sensitive search
mmseqs search \
    ./queryDB/${name} \
    ${DATABASE} \
    ./resultDB/${name} \
    ./tmp \
    -a 1 \
    -s 7.5 \
    -e 1.0E-03 \
    --max-seqs 300 \
    --num-iterations 2 \
    --threads ${T} \
    --cov-mode 2 \
    -c 0.8

# step 3: convert resultDB to output info .tsv file
mmseqs convertalis \
    ./queryDB/${name} \
    ${DATABASE} \
    ./resultDB/${resultname} \
    ./search_outfiles/${resultname}/${resultname}-mmseqs_search-RAW.tsv \
    --format-mode 4 \
    --format-output query,target,pident,evalue,bits,qcov,tcov,qseq,tseq \
    --threads ${T}

# --format-output query,target,pident,evalue,bits,taxid,taxname,taxlineage,qcov,tcov,qstart,qend,qlen,tstart,tend,tlen,qseq,tseq \

# process tsv file to remove non-unique entries, keeping the lowest evalue entries only
awk 'NR>1{print}' ./search_outfiles/${resultname}/${resultname}-mmseqs_search-RAW.tsv |
    sort -k2,2 -k4,4g |
    sort -u -k2,2 |
    sort -k4,4g |
    sed '1i #query\ttarget\tpident\tevalue\tbits\ttaxid\ttaxname\ttaxlineage\tqcov\ttcov\tqstart\tqend\tqlen\ttstart\ttend\ttlen\tqseq\ttseq' >./search_outfiles/${resultname}/${resultname}-mmseqs_search-UNIQUE_hits.tsv
# output fasta file of results
awk 'NR>1{printf(">%s\n%s\n"), $2,$NF}' ./search_outfiles/${resultname}/${resultname}-mmseqs_search-UNIQUE_hits.tsv >./search_outfiles/${resultname}/${resultname}-mmseqs_search-UNIQUE_hits.faa

# return exact query/target hits only
awk 'NR>1{print}' ./search_outfiles/${resultname}/${resultname}-mmseqs_search-UNIQUE_hits.tsv |
    awk '{if ($3 == "100.000"){print} else {next}}' |
    sed '1i #query\ttarget\tpident\tevalue\tbits\ttaxid\ttaxname\ttaxlineage\tqcov\ttcov\tqstart\tqend\tqlen\ttstart\ttend\ttlen\tqseq\ttseq' >./search_outfiles/${resultname}/${resultname}-mmseqs_search-EXACT_hits.tsv
awk 'NR>1{printf(">%s\n%s\n"), $2,$NF}' ./search_outfiles/${resultname}/${resultname}-mmseqs_search-EXACT_hits.tsv >./search_outfiles/${resultname}/${resultname}-mmseqs_search-EXACT_hits.faa

# print list of target IDs
grep -E "^>" ./search_outfiles/${resultname}/${resultname}-mmseqs_search-EXACT_hits.faa |
    sed 's/^>//' >./search_outfiles/${resultname}/${resultname}-hit_IDs.txt

# step 4: convert resultDB to fasta file (2 steps)
# # WARN: is not working! >:(
# mmseqs result2flat \
#     ./queryDB/${name} \
#     ./database/${DATABASE} \
#     ./resultDB/${name} \
#     ./fastaDB/${name} \
#     --use-fasta-header 0
#
# mmseqs convert2fasta \
#     ./fastaDB/${name} \
#     ./search_outfiles/${name}/${name}-mmseqs_search2.faa

# OPTIONAL: taxonomy output

# # step 5: create taxonomyDB of queryDB
# mmseqs taxonomy \
#     ./queryDB/${name} \
#     ./database/${DATABASE} \
#     ./taxaDB/${name}-queryDB \
#     ./tmp \
#     -s 7.5 \
#     --lca-mode 3

# # step 6: create taxonomyDB of resultDB (2 steps)
# mmseqs createdb \
#     ./search_outfiles/${name}/${name}-mmseqs_search.faa \
#     ./result2seqDB/${name} \
#     --dbtype 1

# mmseqs taxonomy \
#     ./result2seqDB/${name} \
#     ./database/${DATABASE} \
#     ./taxaDB/${name}-resultDB \
#     ./tmp \
#     -s 7.5 \
#     --lca-mode 3

# taxonomy reports

# # step 7.1: output taxonomy report of queryDB, krona
# mmseqs taxonomyreport \
#     ./database/${DATABASE} \
#     ./taxaDB/${name}-queryDB \
#     ./search_outfiles/${name}/${name}-krona_taxa_report_of_query.html \
#     --report-mode 1

# # step 7.2: output taxonomy report of queryDB, kraken
# mmseqs taxonomyreport \
#     ./database/${DATABASE} \
#     ./taxaDB/${name}-queryDB \
#     ./search_outfiles/${name}/${name}-kraken_taxa_report_of_query.txt \
#     --report-mode 0

# # step 7.3: output taxonomy report of resultDB, krona
# mmseqs taxonomyreport \
#     ./database/${DATABASE} \
#     ./taxaDB/${name}-resultDB \
#     ./search_outfiles/${name}/${name}-krona_taxa_report_of_search_results.html \
#     --report-mode 1

# # step 7.4: output taxonomy report of resultDB, kraken
# mmseqs taxonomyreport \
#     ./database/${DATABASE} \
#     ./taxaDB/${name}-resultDB \
#     ./search_outfiles/${name}/${name}-kraken_taxa_report_of_search_results.txt \
#     --report-mode 0

# rm -rf ./tmp/*

echo "done!"
