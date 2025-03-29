#!/usr/bin/env python3
"""
Split mmseqs clustered fasta files into separate fasta files for each cluster.
The mmseqs fasta outputs denote different clusters with identical fasta headers ">" on two consecutive lines.
This script scans the fasta file for those identical and consecutive lines, and splits them into separate files.
"""

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
file_count = 0
current_file = None
prev_line = None

# read and process input file
with args.input as infile:
    for line in infile:
        # check if adjacent lines are the same
        if line == prev_line:
            # if lines are the same, close file and create next file
            if current_file is not None:
                current_file.close()
            file_count += 1
            output_filename = f"{file_count:03d}.fasta"
            current_file = open(output_filename, "w")

        # write current line to current file
        if current_file is not None:
            current_file.write(line)

        # iterate to next line
        prev_line = line

# my notes:
# no need to wrap "args.input" in the "with open(args.input, "r") as infile" function...
# just "with args.input as infile" works
