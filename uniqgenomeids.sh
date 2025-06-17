#!/usr/bin/bash

inputfaa=$1

faa2tsv.sh "${inputfaa}" |
    cut -f1 |
    sed 's/___[0-9]*$//' |
    sort -u
