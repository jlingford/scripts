#!/usr/bin/bash

inputdir=$1
chunksize=$2

file_count=0
for file in ${inputdir}/*; do
    dir=CHUNK$(printf %03d $((file_count / chunksize)))
    mkdir -p $dir
    mv $file $dir
    ((file_count++))
done
