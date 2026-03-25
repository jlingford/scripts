#!/usr/bin/env python3
"""
Read genbank file and print size of its DNA (in bp) to stdout

Input:
    - path/to/genbank.gbk

Output:
    - prints two tab-separated columns:
        col1: genbank.gbk
        col2: size

Purpose:
    - needed for filtering sliced genbanks based on size

\033[1m\033[32mTip:\033[0m
    Wrap in a for loop (or gnu-parallel):

        for file in ./*.gbk; do
            gbk_seqsize.py -i "$file" >> genome_sizes.tsv
        done

            ###

        parallel gbk_seqsize.py -i {} >> genome_sizes.tsv ::: ./*.gbk

"""
# TODO:
# - [ ] add ability to read gzipped genbank file

from Bio import SeqIO
from pathlib import Path
import argparse
import gzip
import sys


# =================================================================
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-i",
        "--input",
        dest="input",
        type=Path,
        metavar="IN",
        required=True,
        help="Path to genbank input [Required]",
    )

    args = parser.parse_args()

    return args


# =================================================================
def gbk_length(input_gbk: Path):
    """Read genbank and print DNA size"""
    genome = SeqIO.read(input_gbk, "genbank")
    size = len(genome.seq)
    print(f"{input_gbk.name}\t{size}")


# =================================================================
def main() -> None:
    args = parse_args()
    gbk_length(input_gbk=args.input)


if __name__ == "__main__":
    sys.exit(main())
