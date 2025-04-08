#!/usr/bin/bash

INPUT=$1

awk -F"\n" -vOFS="\t" -vRS=">" -vORS="\n" 'NR>1 { $1=$1; print $0 }' "${INPUT}"
