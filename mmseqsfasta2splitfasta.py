#!/usr/bin/env python3
"""
Plot PAE from alphafold .json files
"""

# input = open('file.faa', 'r').read().split('\n')
input = "./feon-cov80-id20.faa"

file_count = 0
current_file = None
prev_line = None

with open(input, "r") as infile:
    for line in infile:
        # check if adjacent lines are the same
        if line == prev_line:
            # if lines are the same, close file and create next file
            if (
                current_file
            ):  # a check if current_file exists yet during for first loop on file
                current_file.close()
            file_count += 1
            output_filename = f"{file_count:03d}.fasta"
            current_file = open(output_filename, "w")

        # write current line to current file
        if current_file:
            current_file.write(line)

        # iterate to next line
        prev_line = line
