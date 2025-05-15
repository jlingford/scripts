#!/usr/bin/bash

input=$1

awk '
    /^>/ {
        if (NR==1){
            print
        } else {
            printf "\n%s\n", $0
        };
    next;
    }
    { printf "%s", $0}
' ${input}
