#!/usr/bin/env python3
"""
Split mmseqs clustered fasta files into separate fasta files for each cluster.
The mmseqs fasta outputs denote different clusters with identical fasta headers ">" on two consecutive lines.
This script scans the fasta file for those identical and consecutive lines, and splits them into separate files.
"""

import re
import argparse
import pathlib

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

# set output dir with pathlib
pathtofile = args.input.name
new_dir_name = pathtofile.rpartition(".")[0] + "-split_fastas/"
dir = pathlib.Path(new_dir_name)
dir.mkdir(parents=True, exist_ok=True)

# initialize variables
seqs = 0
cluster = 0
passed_first_cluster = False
filename = None
cluster_name = None
prev_line = None
arr = []

# read and process input file
with args.input as infile:
    for line in infile:
        # if two consecutive lines are identical, write output file and reset variables for next cluster of fastas
        if line == prev_line:
            filename = (
                f"{seqs - 1 if seqs > 1 else 1}-seqs_in_cluster-{cluster_name}.faa"
            )
            # write all lines minus the previous line to new file
            if passed_first_cluster is True:
                outpath = dir / filename
                with open(outpath, "w") as outfile:
                    for a in arr[:-1]:
                        outfile.write(a)
            # reset array, make new name for next filename
            arr = []
            cluster_name = re.sub(r"[-]", "_", line.rstrip())
            cluster_name = re.sub(r"[./]", "_", line.rstrip())
            cluster_name = re.sub(r"[>]", "", cluster_name)
            seqs = 0
            passed_first_cluster = True

        # collect line into an array
        arr.append(line)

        # count number of fasta headers in cluster chunk
        if line.startswith(">"):
            seqs += 1

        # iterate to next line
        prev_line = line

    # write last fastas to final file
    if filename is not None:
        filename = f"{seqs - 1 if seqs > 1 else 1}-seqs_in_cluster-{cluster_name}.faa"
        outpath = dir / filename
        with open(outpath, "w") as outfile:
            for a in arr[:-1]:
                outfile.write(a)

# my notes:
# no need to wrap "args.input" in the "with open(args.input, "r") as infile" function...
# just "with args.input as infile" works
# newdir = pathlib.Path(re.search("[a-zA-Z0-9]", args.input.name))
# newdir = re.search("^.*\.", args.input.name).group(0) ## the ".group(0)" returns regex as a string
