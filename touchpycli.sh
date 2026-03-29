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
Description

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
    infile: Path
    outdir: Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-i",
        "--infile",
        type=Path,
        metavar="FILE",
        required=True,
        help="Path to input [Required]",
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

    args = parser.parse_args()

    return Args(**vars(args))


# =============================================================
# Core func.
# =============================================================
def funca(args):
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
    # get args
    args = parse_args()

    # func
    funca(args)


# =============================================================
if __name__ == "__main__":
    sys.exit(main())
EOF
}

template >"${filename}.py"
