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
"""

from Bio import SeqIO
from pathlib import Path
import argparse
import gzip
import json
import logging
import matplotlib.pyplot as plt
import numpy as np
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


def primary_function(args):
    """
    Description

    Args:

    Returns:
    """

    # do stuff...


def main():
    args = parse_arguments()
    primary_function(args)


if __name__ == "__main__":
    exit(main())
EOF
}

template >"${filename}.py"
