#!/usr/bin/bash

DATE=$(date +%Y%m%d)
OUTDIR=./diamond_new_fastas/

# fasta file maker for diamond outputs WITH taxids
func_a() {
    awk -F'\t' 'BEGIN {OFS="\t"} {print $2,$3,$4,$NF}' ${file} |
        sed -n '4,$p' |
        sort -k1 |
        uniq |
        awk -F'\t' '{printf ">%s|%s|%s\n%s\n", $1,$2,$3,$4}' >"${OUTDIR}"/"${filename}-$DATE.faa"
    echo done: ${filename}
}

# fasta file maker for diamond outputs
func_b() {
    awk -F'\t' 'BEGIN {OFS="\t"} {print $2,$NF}' ${file} |
        sed -n '4,$p' |
        sort -k1 |
        uniq |
        awk -F'\t' '{printf ">%s\n%s\n", $1,$2}' >"${OUTDIR}"/"${filename}-$DATE.faa"
    echo done: ${filename}
}

# process diamond output differently depending on taxid inclusion
for file in ./diamond_blastp_outputs/*.tsv; do

    # create new filename var
    filename="${file%-*}"
    filename="${filename##*/}"

    # check for taxids diamond output
    if [[ "${filename}" == *"taxid"* ]]; then
        func_a
    else
        func_b
    fi
done
