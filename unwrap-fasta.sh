#!/usr/bin/bash

input=$1

awk -v W=50 '
    /^>/ { if (seq != "") print seq; print $0; seq = ""; next }
    {
        seq = seq $1
        while (length(seq) > W ) {
            print substr(seq, 1,W)
            seq = substr(seq, 1+W)
        }
    }
    END { if (seq != "") print seq }
' ${input}
