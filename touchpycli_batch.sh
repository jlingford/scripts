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

from Bio import SeqIO
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
from dataclasses import dataclass
from datetime import timedelta
from functools import partial
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
import time


# =============================================================================
# Global config
# =============================================================================

# logger
logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] %(levelname)s -- %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)


# =============================================================================
# CLI args
# =============================================================================
@dataclass
class Args:
    indir: Path
    outdir: Path
    cpu: int
    parallel: bool


def collect_args() -> Args:
    """Argument parser function"""
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    # ===================================================
    mainopts = parser.add_argument_group("Main options")
    mainopts.add_argument(
        "-i",
        "--indir",
        dest="indir",
        type=Path,
        metavar="DIR",
        required=True,
        help="Path to input directory base [Required]",
    )
    mainopts.add_argument(
        "-o",
        "--outdir",
        type=Path,
        required=False,
        default=".",
        metavar="DIR",
        help="Output target directory [Optional][Default: cwd]",
    )
    # ===================================================
    cpuopts = parser.add_argument_group("Parallel processing options")
    cpuopts.add_argument(
        "-C",
        "--cpu",
        type=int,
        default=None,
        metavar="CPU",
        required=False,
        help="Number of CPUs to use for parallelism [Default: max available]",
    )

    cpuopts.add_argument(
        "-P",
        "--parallel",
        action="store_true",
        help="Run script in parallel [Default: runs without parallel processing]",
    )
    # ===================================================

    args = Args(**vars(parser.parse_args()))

    return args


# =============================================================================
# Util
# =============================================================================
def open_gz(file: Path) -> TextIO:
    """Utility function: open file, even if it is gzipped"""
    if file.suffix == ".gz":
        return gzip.open(file, "rt")
    else:
        return open(file, "r")


# ==============================================================================
def collect_dirs(
    base_dir: Path,
) -> list[Path]:
    """Glob for dirs
    ---
    Args:
        base_dir (Path): the base directory to search

    Returns:
        dirs (list[Path]): a list of all dirs
    """
    # glob for all child directories in target dir
    dirs = sorted([p for p in Path(base_dir).rglob("*") if p.is_dir()])
    logger.info(f"Found {len(dirs)} child directories {base_dir}")

    return dirs


# =============================================================================
# Core funcs.
# =============================================================================
def funca(
    infile: Path,
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


# =============================================================================
def main() -> None:
    """Workflow:
    ---
    main
     │
     ├── args
     └── func
    """
    t0 = time.perf_counter()

    args = collect_args()

    dirs = collect_dirs(base_dir=args.indir)

    ############### no parallel processing ##################

    if not args.parallel:
        for infile in infiles:
            funca(infile=infile, outdir=args.outdir, args=args)
        return

    ################# PARALLEL PROCESSING ###################

    if args.parallel:
        # make partial func
        partial_funca = partial(
            funca,
            args=args,
        )
        # ProcessPoolExecutor
        with ProcessPoolExecutor(max_workers=args.cpu) as exe:
            list(exe.map(partial_funca, infiles))

    ################################################################

    t1 = time.perf_counter()
    readable_time = str(timedelta(seconds=int(t1 - t0)))
    logger.info(f"FINISHED in {readable_time} h:m:s")


# =============================================================================
if __name__ == "__main__":
    sys.exit(main())
EOF
}

template >"${filename}.py"
