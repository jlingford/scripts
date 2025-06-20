#!/usr/bin/bash

# USAGE: requires 2 positional arguments:
# curate_clusters.sh INPUT_FILE path/to/output/dir
# NOTE: run in query dir of interest to avoid "fd" pulling off-target files

input=$1
outdir=$2

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: curate_clusters.sh [subset_list_input] [path/to/outdir]"
    >&2 echo "Tip: run at base of directory to avoid accidentally pulling off-target files"
    exit 1
fi

name=${input##*/}
name=${name%%.*}

if [[ ! -d ${outdir}/${name}/${name}-filtered_clusters ]]; then
    mkdir -p ${outdir}/${name}/${name}-filtered_clusters
fi

while read -r rep; do
    # id=${rep/./_/}
    # cp $(fd "${id}") "${outdir}"
    fd "${rep}" --exec cp {} ${outdir}/${name}
done <"${input}"

outfile=${outdir}/${name}/${name}-combined_filtered_clusters.faa

for file in ${outdir}/${name}/*.faa; do
    cat ${file} >>${outfile}
    mv ${file} ${outdir}/${name}/${name}-filtered_clusters
done

echo -e "$(grep -c '^>' ${outfile}):\t${outfile}"
