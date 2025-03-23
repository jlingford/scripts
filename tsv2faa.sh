#!/usr/bin/bash

for file in *.tsv; do
    # without taxids in output results
    awk -F'\t' 'BEGIN {OFS="\t"} {print $2,$NF}' ${file} |
        sed -n '2,$p' |
        sort -k1 |
        uniq |
        awk -F'\t' '{printf ">%s\n%s\n", $1,$2}' >${file%.*}.faa
    echo "done ${file%.*}"
done
