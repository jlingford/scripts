#!/usr/bin/bash

input=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "Usage: $0 [INPUT]"
    exit 1
fi

# Main:
# usage() {
#     echo "
# # --------------------------------------#
# #          $(basename $0) help doc
# # --------------------------------------#
# Usage: $0 INPUT
#
# Required params:
#     INPUT      Path to input file
#     -l INT     Size of chunks as number of seqs per file
#
# Info:
#     -h, --help           Print help
#
# Description:
#     Takes a large fasta file and splits it into smaller chunks
# "
# }
#
# #--------------------------------------------------------------------#
# # Defining getop params
# #--------------------------------------------------------------------#
# # create command line options with getopt
# opt_short="i:o:h"
# opt_long="input:,output:,help"
# OPTS=$(getopt -o "$opt_short" --long "$opt_long" -n 'parse-options' -- "$@")
#
# # If wrong option is given, print error message.
# if [[ $? -ne 0 ]]; then
#     echo "Error: Wrong input parameter used!"
#     usage
#     exit 1
# fi

input=$1

name=${input##*/}
name=${name%.*}
outdir=${name}_SPLIT_FASTAS

mkdir -p "$outdir"

faa2tsv.sh "$input" |
    (cd "$outdir" && split -a 3 -d -l 2000 - "${name}"_CHUNK)

for file in "${outdir}"/*; do
    tsv2faa.sh "$file" >"${file}".faa && rm "$file"
done
