#!/usr/bin/env python3
"""
Split mmseqs clustered fasta files into separate fasta files for each cluster.
The mmseqs fasta outputs denote different clusters with identical fasta headers ">" on two consecutive lines.
This script scans the fasta file for those identical and consecutive lines, and splits them into separate files.
"""

import re
import argparse

# accept one positional argument (the input file)
parser = argparse.ArgumentParser(
    description="take input fasta file from mmseqs clustering and split them into separate fasta files"
)
parser.add_argument(
    "input",
    metavar="FILE",
    type=argparse.FileType("r"),
    help="provide a path/to/file.faa",
)
args = parser.parse_args()


# initialize variables
seqs = 0
cluster = 0
passed_first_chunk = False
filename = None
cluster_name = None
prev_line = None
arr = []

# read and process input file
with args.input as infile:
    for line in infile:
        # check if two consecutive lines are identical
        if line == prev_line:
            filename = (
                f"{seqs - 1 if seqs > 1 else 1}-seqs-{cluster_name}-cluster.fasta"
            )
            # write all lines minus the previous line to new file
            if passed_first_chunk is True:
                with open(filename, "w") as outfile:
                    for a in arr[:-1]:
                        outfile.write(a)
            # reset array, make new name for next filename
            arr = []
            cluster_name = re.sub(r"[./]", "-", line.rstrip())
            cluster_name = re.sub(r"[>]", "", cluster_name)
            seqs = 0
            passed_first_chunk = True

        # collect line into an array
        arr.append(line)

        # count number of fasta headers in cluster chunk
        if line.startswith(">"):
            seqs += 1

        # iterate to next line
        prev_line = line

    # write last fastas to final file
    if filename is not None:
        filename = f"{seqs - 1 if seqs > 1 else 1}-seqs-{cluster_name}-cluster.fasta"
        with open(filename, "w") as outfile:
            for a in arr[:-1]:
                outfile.write(a)

# my notes:
# no need to wrap "args.input" in the "with open(args.input, "r") as infile" function...
# just "with args.input as infile" works
