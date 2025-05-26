#!/usr/bin/env python3

"""
Calculate all prime numbers from 1 to N (with N being a number of choice to input).
"""

import sys
import argparse
from pathlib import Path
import pathlib
from typing import NamedTuple, TextIO


# -------------------------------------
class Args(NamedTuple):
    """Define data types for each commandline argument"""

    number: int
    infile: TextIO
    outfile: Path
    verbosity: int


# -------------------------------------
def cmdline_args() -> Args:
    """Get arguments from command line"""

    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-n",
        "--number",
        metavar="<N>",
        type=int,
        help="provide an integer input",
        # default="100",
    )

    parser.add_argument(
        "-f",
        "--file_input",
        metavar="<INPUT_FILE>",
        type=argparse.FileType("r"),
        help="provide a path/to/file containing an integer input",
    )

    parser.add_argument(
        "-o",
        "--output_file",
        metavar="<OUTPUT_FILE>",
        type=pathlib.Path,
        # type=str,
        help="output results to path/to/file",
    )

    parser.add_argument(
        "-v",
        "--verbosity",
        type=int,
        choices=[0, 1],
        default=0,
        help="increase output verbosity (default: %(default)s)",
    )

    # print help if no arguments are given
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit()

    # assign args shorthand
    args = parser.parse_args()

    # returns object with previously defined data type
    return Args(
        number=args.number,
        infile=args.file_input,
        outfile=args.output_file,
        verbosity=args.verbosity,
    )


# -------------------------------------
def process_input() -> int:
    """Convert text from input file to int for primes() function"""

    # get command line arguments
    args = cmdline_args()

    # define input for primes() function
    n: int = 1

    # get input from command line arguments
    if args.number:
        n = args.number
    elif args.infile:
        with args.infile as f:
            text_input = f.read().rstrip()
        n = int(text_input)

    return n


# ---------------------------------------
def process_output() -> None | Path:
    """Create output file (and directory to file if specified)"""

    # get command line arguments
    args = cmdline_args()

    # define output
    outdir = None

    # create output file and parent directory if cmdline_arg was given
    if args.outfile:
        outdir = args.outfile
        if not outdir.exists():
            outdir.parent.mkdir(parents=True, exist_ok=True)
            outdir.touch()

    return outdir


# ---------------------------------------
def primes(n: int) -> list[int]:
    """Return a list of the first n primes"""

    sieve: list[bool] = [True] * n

    result: list[int] = []

    for i in range(2, n):
        if sieve[i]:
            result.append(i)
            for j in range(i * i, n, i):
                sieve[j] = False

    return result


# --------------------------------------------
def main() -> None:
    """Main function"""

    # call cmdline functions
    n: int = process_input()
    outdir: None | Path = process_output()

    # call primes function
    result: list = primes(n)

    # OUTPUT
    # write result of primtes() to output file if command line arg was given
    if outdir is not None:
        with open(outdir, "w") as f:
            f.write(str(result))

        print(f"Output file created at {outdir}")
    else:
        # print result of primes() to stdout
        print(result)


# --------------------------------------------
if __name__ == "__main__":
    main()
