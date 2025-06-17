#!/usr/bin/bash

fd seqs.faa |
    awk -F"/" '{print $NF}' |
    sort |
    awk -F"-" -vOFS="\t" '{print $1, $(NF-6), $(NF-5), $(NF-3), $(NF-2), $(NF-4),  $NF}' |
    sed 's/id//' |
    sed 's/_seqs.faa//' |
    sed '1i #name\tdetails\tcoverage\tcov-mode\tcluster-mode\tseqid\tno_rep_seqs'
