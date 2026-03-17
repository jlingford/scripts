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
# TODO
# - [ ]

from Bio import SeqIO
from concurrent.futures import ProcessPoolExecutor
from functools import partial
from itertools import combinations
from pathlib import Path
import argparse
import gzip
import json
import logging
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import polars as pl
import re
import seaborn as sns
import shutil
import subprocess
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        "-i",
        "--input",
        dest="input",
        type=Path,
        metavar="IN",
        required=True,
        help="Path to input [Required]",
    )

    parser.add_argument(
        "-o",
        "--outdir",
        dest="outdir",
        type=Path,
        required=False,
        default=".",
        metavar="DIR",
        help="Output target directory [Optional][Default: cwd]",
    )

    args = parser.parse_args()

    if not args.input.exists():
        parser.error(f"Input does not exist: {args.input}")

    return args


def funca(args):
    """Description

    Args:
        arg1 (dtype): description

    Returns:
        dtype: description
    """

    # do stuff...
    print("Hello world")


def main():
    args = parse_args()
    funca(args)


if __name__ == "__main__":
    sys.exit(main())
EOF
}

template >"${filename}.py"
