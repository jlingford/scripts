#!/usr/bin/bash

subset=$1
table=$2

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: $0 [SUBSET_LIST] [TABLE]"
    exit 1
fi

(
    grep -f "${subset}" "${table}" | awk 'BEGIN{OFS="\t"} {print "YES", $0}'
    grep -v -f "${subset}" "${table}" | awk 'BEGIN{OFS="\t"} {print "NO", $0}'
) |
    sort
