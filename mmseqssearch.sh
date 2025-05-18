#!/usr/bin/bash

# vars
name=""
FASTA_INPUT=""
DATABASE="GTDB_r226/gtdb226"
T=95

# step 1: create sequenceDB out of fastas
mmseqs createdb \
    ./fastainputs/${FASTA_INPUT} \
    ./queryDB/${name} \
    --dbtype 1

# step 2: search
mmseqs search \
    ./queryDB/${name} \
    ./database/${DATABASE} \
    ./resultDB/${name} \
    ./tmp \
    -a 1 \
    -s 7.5 \
    -e 1.0E-03 \
    --max-seqs 300 \
    --num-terations 2 \
    --threads ${T} \
    --cov-mode 2 \
    -c 0.8

# step 3: convert resultDB to output info .tsv file
mmseqs convertalis \
    ./queryDB/${name} \
    ./database/${DATABASE} \
    ./resultDB/${name} \
    ./outfiles/${name}/${name}-mmseqs_search.tsv \
    --format-mode 4 \
    --format-output query,target,pident,evalue,bits,taxid,taxname,taxlineage,qcov,tcov,qstart,qend,qlen,tstart,tend,tlen,qseq,tseq \
    --threads ${T}

# step 4: convert resultDB to fasta file
mmseqs convert2fasta \
    ./resultDB/${name} \
    ./outfiles/${name}/${name}-mmseqs_search.faa

# optional: taxonomy output

# step 5: create taxonomyDB of queryDB
mmseqs taxonomy \
    ./queryDB/${name} \
    ./database/${DATABASE} \
    ./taxaDB/${name}-queryDB \
    ./tmp \
    -s 7.5 \
    --lca-mode 3

# step 6: create taxonomyDB of resultDB
mmseqs taxonomy \
    ./resultDB/${name} \
    ./database/${DATABASE} \
    ./taxaDB/${name}-resultDB \
    ./tmp \
    -s 7.5 \
    --lca-mode 3

# taxonomy reports

# step 7.1: output taxonomy report of queryDB, krona
mmseqs taxonomyreport \
    ./database/${DATABASE} \
    ./taxaDB/${name}-queryDB \
    ./outfiles/${name}/${name}-krona_taxa_report_of_query.html \
    --report-mode 1

# step 7.2: output taxonomy report of queryDB, kraken
mmseqs taxonomyreport \
    ./database/${DATABASE} \
    ./taxaDB/${name}-queryDB \
    ./outfiles/${name}/${name}-kraken_taxa_report_of_query.html \
    --report-mode 0

# step 7.3: output taxonomy report of resultDB, krona
mmseqs taxonomyreport \
    ./database/${DATABASE} \
    ./taxaDB/${name}-resultDB \
    ./outfiles/${name}/${name}-krona_taxa_report_of_search_results.html \
    --report-mode 1

# step 7.4: output taxonomy report of resultDB, kraken
mmseqs taxonomyreport \
    ./database/${DATABASE} \
    ./taxaDB/${name}-resultDB \
    ./outfiles/${name}/${name}-kraken_taxa_report_of_search_results.html \
    --report-mode 1

echo "done!"
