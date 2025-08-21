#!/usr/bin/bash

# input
map_table=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "Usage: $0 [INPUT]"
    exit 1
fi

# Main:
for dir in GCF*; do
    name="${dir##*/}"
    new_name=$(grep "$name" "$map_table" | awk -F"\t" '{printf "%s_Group_%s_%s", $2, $3, $4}')
    # echo mv "$dir" "${new_name}___${dir}"
    mv "$dir" "${new_name}___${dir}"
done
