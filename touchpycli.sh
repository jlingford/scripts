#!/usr/bin/bash

filename=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: $(basename $0) [NEW_FILE_NAME]"
    exit 1
fi

touch ${filename}.sh
chmod u+x ${filename}.sh

template() {
    cat <<'EOF'
#!/usr/bin/env python3
"""
Small python script
"""

import os
import re
import sys
import shutil
import argparse
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from Bio import SeqIO
from pathlib import Path


def parse_arguments():
    # Initialize argparse
    parser = argparse.ArgumentParser(
        description="Description goes here",
        epilog="Example %(prog)s -i INPUT [-o OUTPUT]"
    )

    # Add arguments
    parser.add_argument(
        "-i",
        "--input",
        dest="input_file",
        type=Path,
        required=True,
        help="Path to input file (required)."
    )

    parser.add_argument(
        "-o",
        "--output",
        dest="output_file",
        type=Path,
        default=Path("."),
        required=False,
        help="Path to output file. [Default: current dir]"
    )

    # Parse arguments into args object
    args = parser.parse_args()

    # Validate arguments
    if not args.input_file.is_file():
        parser.error(f"Input file does not exist or is not a file: {args.input_file}")

    if not args.output_file.is_dir():
        parser.error(f"Output directory does not exist or is not a directory: {args.output_dir}")

    return args


def func(args):
    """
    Stuff goes here
    """
    # do stuff...


def main():
    args = parse_arguments()
    primary_function(args)


if __name__ == "__main__":
    main()
EOF
}

template >"${filename}.sh"
