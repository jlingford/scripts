#!/usr/bin/bash

filename=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: $(basename $0) [NEW_FILE_NAME]"
    exit 1
fi

touch "${filename}.py"
chmod +x "${filename}.py"

template() {
    cat <<'EOF'
#!/usr/bin/env python3
"""
BATCH Description

Input:
    ...
Output:
    ...
Purpose:
    ...
Prerequisites:
    ...
\033[1m\033[31mWARNING:\033[0m
    ...

"""
# TODO:
# - [ ]

from concurrent.futures import ProcessPoolExecutor
from functools import partial
from Bio import SeqIO
from itertools import combinations
from pathlib import Path
from typing import TextIO, NamedTuple
import argparse
import gzip
import logging
import numpy as np
import polars as pl
import shutil
import subprocess
import sys


# =================================================================
# CLI args
# =================================================================
class Args(NamedTuple):
    indir: Path
    outdir: Path
    cpu: int
    no_parallel: bool


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-i",
        "--indir",
        type=Path,
        metavar="FILE",
        required=True,
        help="Path to input dir [Required]",
    )

    parser.add_argument(
        "-o",
        "--outdir",
        type=Path,
        required=False,
        default=".",
        metavar="DIR",
        help="Output target directory [Optional][Default: cwd]",
    )

    parser.add_argument(
        "-c",
        "--cpu",
        type=int,
        default=None,
        metavar="N",
        required=False,
        help="No. of CPUs to use for parallelism [Default: max available]",
    )

    parser.add_argument(
        "--no_parallel",
        action="store_true",
        help="Run script synchronously, not in parallel",
    )

    args = parser.parse_args()

    return Args(**vars(args))


# =============================================================
# Util
# =============================================================
def open_gz(file: Path) -> TextIO:
    """Utility function: open file, even if it is gzipped"""
    if file.suffix == ".gz":
        return gzip.open(file, "rt")
    else:
        return open(file, "r")


# =============================================================
# Core funcs.
# =============================================================
def funca(
    infile: Path,
    outdir: Path,
    args: Args,
    ) -> None:
    """Description

    ---
    Args:
        arg1 (dtype): description

    Returns:
        dtype: description
    """
    # stuff
    print("Hello world")


# =============================================================
def main() -> None:
    """Workflow:
    ---
    main
     ├── args
     └── func
     │
    """
    # get cli args
    args = parse_args()

    # get all input files
    file_searcher = Path(args.indir).glob("*.faa")
    infiles = sorted([f for f in file_searcher if f.is_file()])

    ############### no parallel processing ##################

    if args.parallel:
        for infile in infiles:
            funca(infile=infile, outdir=args.outdir, args=args)
        return

    ################# PARALLEL PROCESSING ###################

    # make partial func
    partial_funca = partial(
        funca,
        outdir=args.outdir,
        args=args,
    )
    # ProcessPoolExecutor
    with ProcessPoolExecutor(max_workers=args.cpu) as exe:
        list(exe.map(partial_funca, infiles))


# =============================================================
if __name__ == "__main__":
    sys.exit(main())
EOF
}

template >"${filename}.py"
