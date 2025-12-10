#!/usr/bin/bash

# script for truncating the C-terminal sequence of a NiFe hydrogenase
# for the purpose of AlphaFold heterodimer prediction.
# The C-terminal sequence is often removed by the endopeptidase
# HypD (NiFe hydrogenase maturation factor).
# Not removing this sequnece can mess with the AlphaFold prediction
# and alter the metalloactive site, since it clashes with the SSU.
# This script uses simple regex and sed for truncating the C-terminal
# sequence. Seqkit and ripgrep are required dependencies.

input=$1

# set regex to find in NiFe sequence here
REGEX="C..C.*C..C..[HR]"

name=${input##*/}
name=${name%.*}

# convert faa to tsv
seqkit fx2tab -iQ "$input" |
    # get only lines that match REGEX
    rg $REGEX |
    # append suffix to header
    awk -F"\t" -vOFS="\t" '{print $1"-Ctermtrunc1", $2}' |
    # truncate the sequence after REGEX using sed
    sed -E "s/($REGEX).*$/\1/" |
    # convert back to faa and write file
    seqkit tab2fx \
        >${name}-Ctermtrun1.faa
