#!/usr/bin/bash

# USAGE: requires 2 positional arguments:
# curate_clusters.sh INPUT_FILE path/to/output/dir
# NOTE: run in query dir of interest to avoid "fd" pulling off-target files

input=$1
outdir=$2

if [[ ! -d $outdir ]]; then
    mkdir -p "$outdir"
fi

while read -r clustrep; do
    id=${clustrep/./_}
    cp $(fd ${id}) ${outdir}
done <"${input}"
