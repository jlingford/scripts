#!/usr/bin/bash

# script for condensing KOFam .tbl output
# WARN: assumes gzipped .tbl.gz file

# init vars
INPUT=$1
OUTDIR="./KOFAMscan_cleaned_tbl_outputs"
mkdir -p $OUTDIR

name=${INPUT##*/}
name=${name%%.*}
outfile=${OUTDIR}/${name}_clean.tbl

# strip "*", strip leading whitespace, and get top evalue gene (genes are pre-sorted from lowest to highest evalues)
zcat "$INPUT" |
    grep -v "#" |
    sed 's#^\* ##' |
    sed 's#^\s*##' |
    sort -u -k1,1 >"$outfile"

gzip "$outfile"
