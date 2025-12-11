#!/usr/bin/bash

# script for truncating the C-terminal sequence of a NiFe hydrogenase
# for the purpose of AlphaFold heterodimer prediction.
# The C-terminal sequence is often removed by the endopeptidase
# HypD (NiFe hydrogenase maturation factor).
# Not removing this sequnece can mess with the AlphaFold prediction
# and alter the metalloactive site, since it clashes with the SSU.
# This script uses simple regex and sed for truncating the C-terminal
# sequence. Seqkit and ripgrep are required dependencies.

# Need to compile all NiFe LSU SSU heterodimer fasta files into one pooled tsv, with 4 columns
# (lsu_header, lsu_seq, ssu_header, ssu_seq), then run regex search and trimming protocol,
# then output each two different types of fasta files: 1) new boltz input fastas (one row for two seq fasta),
# and 2) compiled fasta for colabfoldsearch input

# run at base of gene extraction script output to copy all relevant fasta files over to one convenient directory
mkdir -p boltz_fastas_lsussu/{untrimmed,trimmed}

fd AFformat_Boltz2_NiFeLSUSSU -e fasta -t f -d 4 -E boltz_fastas_lsussu |
    rsync -auvz --info=progress2 --no-relative --files-from=- . boltz_fastas_lsussu/untrimmed

cd boltz_fastas_lsussu || exit

# now build a tsv file of all boltz fastas pooled
for fasta in ./untrimmed/*.fasta; do
    cat "$fasta" |
        # wrap multiline fasta so seq is on one line
        awk '/^>/ { if(NR==1) {print $0;} else {printf "\n%s\n",$0;} next; } { printf "%s",$0 }' |
        # convert heterodimer fasta into 4 column tsv file
        tr '\n' '\t' |
        # need to add newline to end of file to end the row
        sed 's/$/\n/' \
            >>boltz_untrimmed_lsussu.tsv
done

# now trim C-terminal end of NiFe LSU, and rename its fasta header
# set regex to find in NiFe sequence here
REGEX="C..C.*C..C..[HR]"

# search for matching NiFe motif (only for LSU)
grep "\t.*$REGEX" boltz_untrimmed_lsussu.tsv |
    # trim sequence after REGEX using sed
    sed -E "s/($REGEX)[^\t]+\t/\1\t/" |
    # edit the LSU header
    sed -E "s/(^[^\t]+)\.a3m/\1-Ctermtrunc1.a3m/" \
        >boltz_TRIMMED_lsussu.tsv

# now convert this new tsv into two new forms of fasta output
# 1. Boltz input fastas

# use while read loop since it's easier to make output file names than using awk
while IFS=$'\t' read -r col1 col2 col3 col4; do

    # get LSU ID and num
    name1=$(echo $col1 | sed 's/^.*\///' | sed 's/-Cterm.*$//')
    # get SSU num
    name2=$(echo $col3 | sed 's/^.*___//' | sed s/\.a3m//)
    # make output fasta name
    outputname="${name1}-${name2}_Ctermtrim.fasta"

    # use printf to convert columns from tsv into fasta format (replace tabs with newlines)
    printf "%s\n%s\n%s\n%s\n" $col1 $col2 $col3 $col4 >trimmed/$outputname

done <boltz_TRIMMED_lsussu.tsv

# 2. ColabFold search output
awk -F"\t" '{printf "%s\n%s\n%s\n%s\n", $1,$2,$3,$4}' boltz_TRIMMED_lsussu.tsv |
    # remove boltz stuff and file path from header
    sed '/^>/ s#>.*/#>#' |
    # remove .a3m file extension from header
    sed '/^>/ s#\.a3m$##' \
        >colabfoldbatch_TRIMMED_lsussu.faa

# SCRAP
# seqkit fx2tab -iQ "$input" |
#     # get only lines that match REGEX
#     rg $REGEX |
#     # append suffix to header
#     awk -F"\t" -vOFS="\t" '{print $1"-Ctermtrunc1", $2}' |
#     # truncate the sequence after REGEX using sed
#     sed -E "s/($REGEX).*$/\1/" |
#     # convert back to faa and write file
#     seqkit tab2fx \
#         >${name}-Ctermtrun1.faa
