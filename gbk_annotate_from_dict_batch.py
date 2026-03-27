#!/usr/bin/env python3
"""
BATCH writes gene annotation to Genbank files from pre-made dictionary pickle file

Input:
    - Target directory containing Genbank file for updating
    - Pickled dictionary file containing all gene names and associated annotations

Output:
    - Genbank files with new CDS annotations

Purpose:
    To add annotation info to Genbank file. Useful for downstream application for plotting gene neighbourhoods (clinker + gggenes). Also useful for outputting .faa files with descriptions in the header.

Prerequisites:
    Need to have ran gbk_kofam_to_pkldict.py first to generate the pkl file

\033[1m\033[31mWARNING:\033[0m
    Memory intensive. Pickled dict of a 5GB size requires ~12GB MEM per CPU
"""
# TODO:
# - [ ]

from Bio import SeqIO
from concurrent.futures import ProcessPoolExecutor
from functools import partial
from io import TextIOWrapper
from pathlib import Path
import argparse
import gzip
import logging
import pickle
import sys
import warnings
import os

# =============================================================
# ignore biopython warnings, which just clog up the STDOUT
warnings.filterwarnings("ignore")

# default cpu count = max cpus available
CPU = os.cpu_count()


# =============================================================
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-g",
        "--genbank_indir",
        dest="input_dir",
        type=Path,
        metavar="DIR",
        required=True,
        help="Path to target directory containing Genbank files to add annotations to (.gbk files) [Required]",
    )

    parser.add_argument(
        "-d",
        "--dict",
        dest="pkl_dict_path",
        type=Path,
        metavar="PKL",
        required=True,
        help="Path to pickled dictionary of gene_names and corresponding annotations (.pkl file) [Required]",
    )

    parser.add_argument(
        "-c",
        "--cpu",
        dest="cpu",
        type=int,
        default=CPU,
        metavar="N",
        required=False,
        help="No. of CPUs to use for parallelism [Default: max available]",
    )

    parser.add_argument(
        "-o",
        "--outdir",
        dest="outdir",
        type=Path,
        required=False,
        default="./Genbanks_annotated",
        metavar="DIR",
        help="Path output directory for faa files [Default: $(pwd)/Genbanks_annotated/ ]",
    )

    parser.add_argument(
        "--modify_inplace",
        dest="modify_inplace",
        action="store_true",
        help="Overwrites the original/input Genbank files with the updated annotated Genbank [Default: off, writes new Genbank file]",
    )

    parser.add_argument(
        "--skip_existing",
        dest="skip_existing",
        action="store_true",
        help="If annotated genbank file has already been written, skips it without overwriting",
    )

    parser.add_argument(
        "--no_parallel",
        dest="no_parallel",
        action="store_true",
        help="Will synchronously, not in parallel. Good for few inputs, very slow for many inputs",
    )

    args = parser.parse_args()

    return args


# =============================================================
def open_gz(filepath: Path) -> TextIOWrapper:
    """Utility function: open file, even if it is gzipped"""
    if filepath.suffix == ".gz":
        return gzip.open(filepath, "rt")
    else:
        return open(filepath, "r")


# =============================================================
def load_pickled_dict(pkl_dict_path: Path) -> dict[str, str]:
    """Utility function: load pickle file and return data"""
    with open(pkl_dict_path, "rb") as f:
        pkl_dict = pickle.load(f)
        return pkl_dict


# =============================================================
def update_genbank_descs(
    genbank_input: Path,
    kofam_dict: dict[str, str],
    outdir: Path,
    args: argparse.Namespace,
) -> None:
    """Add gene annotation information into a Genbank file

    ---
    Args:
        genbank_input (Path): path to the genbank file
        kofam_dict (dict[str, str]): dictionary of KOfam annotations ({gene_name: description})
        outdir (Path): path to the output directory to write results to
        args: other arguments

    Returns:
        None: writes new Genbank file with annotation information
    """
    ################ set output gbk file ########################
    if args.modify_inplace is True:
        outpath = genbank_input
    else:
        outpath = Path(outdir) / f"{genbank_input.stem}_updated.gbk"
        outpath.parent.mkdir(parents=True, exist_ok=True)
        # skip previously written file option
        if args.skip_existing and outpath.exists():
            print(f"Skipping: Genbank file already written: {outpath}")
            return None

    ################ read and write genbank files, streaming style ####################
    with open_gz(genbank_input) as infile, open(outpath, "w") as outfile:
        # read infile and modify features.qualifiers of genbank record
        for rec in SeqIO.parse(infile, "genbank"):
            for feat in rec.features:
                if feat.type != "CDS":
                    continue

                # feat.qualifiers is a dict[str, list[str]]; get gene_name from "locus_tag" key
                gene_name = feat.qualifiers.get("locus_tag", [0])[0]

                # get kofam annotation for gene
                kofam_desc = kofam_dict.get(gene_name, None)

                # features.qualifiers is a dict; can easily update it with an annotation key,val pair
                if kofam_desc is None:
                    # feat.qualifiers["annotation"] = "None"
                    feat.qualifiers.update({"annotation": "None"})
                else:
                    # feat.qualifiers["annotation"] = kofam_desc
                    feat.qualifiers.update({"annotation": kofam_desc})

            # write update genbank record to outfile
            SeqIO.write(rec, outfile, "genbank")

    # logging
    print(f"Written annotations to {genbank_input}")


# =============================================================
def main() -> None:
    """Workflow:
    ---
    main
     └── ProcessPoolExecutor
          └── update_genbank_descs
    """
    # parse args
    args = parse_args()

    # get all tbls in target dir
    genbank_files = sorted(
        [f for f in Path(args.input_dir).glob("*.gbk*") if f.is_file()]
    )

    # load dictionary from pkl
    kofam_dict = load_pickled_dict(pkl_dict_path=args.pkl_dict_path)

    ################## PARALLEL PROCESSING ######################

    if args.no_parallel:
        # run synchronously:
        for gbk in genbank_files:
            update_genbank_descs(
                genbank_input=gbk,
                kofam_dict=kofam_dict,
                outdir=args.outdir,
                args=args,
            )
    else:
        # run in PARALLEL
        partial_update_genbank_descs = partial(
            update_genbank_descs,
            kofam_dict=kofam_dict,
            outdir=args.outdir,
            args=args,
        )
        with ProcessPoolExecutor(max_workers=args.cpu) as exe:
            list(exe.map(partial_update_genbank_descs, genbank_files))


# =============================================================
if __name__ == "__main__":
    sys.exit(main())
