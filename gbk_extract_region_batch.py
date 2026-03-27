#!/usr/bin/env python3
"""
BATCH extracts the genomic neighbourhoods of target genes from Genbank files.

Input:
    - path to the input table
        Input list should have three tab-separated fields per line:

            col1: path/to/genbankfile.gbk
            col2: target gene ID
            col3: path to output directory

    - size of region to slice upstream and downstream of the target gene (Default: ±10,000 bp)

Output:
    - writes a 'sliced' genbank file to output directory. File naming format is:

            `<genomeID>___<targetgeneID>-genomic_region.gbk`

Purpose:
    - to get smaller genbank files of a target genes genomic context, which can be provided to programs like 'clinker' or 'gggenes' for plotting/visualising the genomic context

\033[1m\033[32mTip for running multiple jobs in batch:\033[0m
    Write a tab-separated table (.tsv) with the path to genbank input, target gene ID, output dir, etc. E.g.,

        `path/to/genbank1.gbk   gene_ID    path/to/output`

    To generate this .tsv easily, run this bash script within your target directory filled with genbank files:

        ```
        # requires "ripgrep" to be installed
        # use -d 1 to control max depth ripgrep searches to
        # -F: fixed strings (very important for exact match)
        # $(pwd) will add the absolute path to the output

        rg -d 1 -F -f YOUR_GENE_ID_LIST.txt $(pwd) |
            sed 's/://' |
            sed 's#/locus_tag="##' |
            sed 's/"$//' |
            sed 's#$#\\tPATH_TO_YOUR_OUTDIR#' |
            awk -vOFS="\\t" '{$1=$1}1'
            > NAME_OF_INDEX.tsv
        ```

"""
# TODO:
# - [ ] add logging
# - [x] add ability to read gzipped genbank files

from concurrent.futures import ProcessPoolExecutor
from functools import partial
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqFeature import SeqFeature, FeatureLocation
from Bio.SeqFeature import SimpleLocation
from Bio.SeqRecord import SeqRecord
from pathlib import Path
from typing import TextIO
import argparse
import sys
import gzip
import warnings


# =======================================================================
# ignore biopython warnings, which just clog up the STDOUT
warnings.filterwarnings("ignore")


# =======================================================================
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "-i",
        "--input_list",
        dest="input_list",
        type=Path,
        metavar="TSV",
        required=True,
        help="Path to input .tsv with list of inputs. Columns should be COL1: path/to/genbank; COL2: target gene ID; COL3: path to output directory [Required]",
    )

    parser.add_argument(
        "-u",
        "--upstream",
        dest="upstream",
        type=int,
        required=False,
        default=10000,
        metavar="INT",
        help="Size of upstream window in bp [Default: 10000]",
    )

    parser.add_argument(
        "-d",
        "--downstream",
        dest="downstream",
        type=int,
        required=False,
        default=10000,
        metavar="INT",
        help="Size of downstream window in bp [Default: 10000]",
    )

    parser.add_argument(
        "-c",
        "--cpu",
        dest="cpu",
        type=int,
        default=None,
        metavar="N",
        required=False,
        help="No. of CPUs to use for parallelism [Default: max available]",
    )

    parser.add_argument(
        "--not_clinker_safe",
        dest="not_clinker_safe",
        action="store_true",
        required=False,
        help="Default behaviour redefines gene coordinates and removes any genes that overlap with upstream/downstream boundaries. This is ideal for `clinker`, but maybe not for `gggenes`. This flag turns this behaviour off.",
    )

    parser.add_argument(
        "--no_overwrite",
        dest="no_overwrite",
        action="store_true",
        required=False,
        help="If sliced genbank already exists in output, do not overwrite it [Default: Disabled]",
    )

    args = parser.parse_args()

    return args


# =============================================================
def open_gz(file: Path) -> TextIO:
    """Utility function: open file, even if it is gzipped"""
    if file.suffix == ".gz":
        return gzip.open(file, "rt")
    else:
        return open(file, "r")


# =======================================================================
def find_target_location(
    gbk_file: Path,
    target_gene: str,
    args: argparse.Namespace,
) -> tuple[SeqRecord, SimpleLocation]:
    """Finds target gene in Genbank and returns its location coordinates and the contig its on (i.e., "feature")

    ---
    Args:
        gbk_file (Path): path to full genbank input file
        target_gene (str): ID of target gene

    Returns:
        full_rec (SeqRecord): the full contig (feature) the target gene is located on (biopython object)
        target_loc (SimpleLocation): the location coordinates of the target_gene (biopython object)
    """
    # init empty var
    full_rec: SeqRecord = None
    target_loc: SimpleLocation = None

    ############## read genbank file for target_gene #################
    with open_gz(file=gbk_file) as infile:
        for rec in SeqIO.parse(infile, "genbank"):
            # loop over genbank features to get to target_gene_id
            for feat in rec.features:
                if feat.type != "CDS":
                    continue

                # feat.qualifiers is a dict[str, list[str]]; get gene_name from locus_tag
                gene_name = feat.qualifiers.get("locus_tag", [0])[0]

                # return info
                if target_gene == gene_name:
                    target_loc = feat.location
                    full_rec = rec

                    return full_rec, target_loc

    # error logging if nothing matches
    raise Exception("Target gene not found in genome")


# =======================================================================
def slice_genbank(
    genbank_input: Path,
    target_gene: str,
    outdir: Path,
    upstream: int,
    downstream: int,
    args: argparse.Namespace,
) -> None:
    """Slice a Genbank file into a smaller region surrounding a target gene

    ---
    Args:
        genbank_input (Path): path to full genbank input file
        target_gene (str): ID of target gene (must match ID on genome)
        outdir (Path): path to the output directory (default = cwd)
        upstream (int): size of region upstream of target_gene (bp)
        downstream (int): size of region downstream of target_gene (bp)
        args (argparse): other args

    Returns:
        None: writes a sliced genbank file to output directory
    """
    # find target_gene location and its associated genbank "record" (contig)
    full_rec, target_loc = find_target_location(
        gbk_file=genbank_input, target_gene=target_gene, args=args
    )

    # init vars
    UPSTREAM = upstream
    DOWNSTREAM = downstream
    tstart = int(target_loc.start)
    tend = int(target_loc.end)
    tstrand = int(target_loc.strand)
    full_rec_len = len(full_rec.seq)  # length of contig

    # ====================================
    # STEP 1. slice the genbank record based on window coords

    # calculte window coords for + strand
    win_start = max(0, tstart - UPSTREAM)
    win_end = min(full_rec_len, tend + DOWNSTREAM)

    # get window coords based if - strand (everything is reverse)
    if tstrand == -1:
        tstart, tend = tend, tstart
        UPSTREAM, DOWNSTREAM = DOWNSTREAM, UPSTREAM
        win_start = max(0, tstart - UPSTREAM)
        win_end = min(full_rec_len, tend + DOWNSTREAM)

    # slice the sequence
    extracted_seq = full_rec.seq[win_start:win_end]

    # create new smaller gbk record of extracted_seq, but lacks features
    sliced_rec = SeqRecord(
        seq=Seq(extracted_seq),
        id=f"{full_rec.id}",
        name=f"{full_rec.name}",
        description=f"Neighbourhood around {target_gene}: +{UPSTREAM}bp and -{DOWNSTREAM}bp",
    )

    # ====================================
    # STEP 2. remove CDSs that overlap with boundary of upstream/downstream window

    # find genes that overlap with boundary of window cutoff, skip them, add valid feats to extracted_features
    neighbour_feats = []
    for feat in full_rec.features:
        if feat.type != "CDS":
            continue

        # get CDS coords
        cds_start = int(feat.location.start)
        cds_end = int(feat.location.end)

        ######################## CLINKER SAFE OPTION: ###############################
        # define location and genes to exclude based on the "clinker safe" option or not:
        if args.not_clinker_safe is not True:
            # exclude genes outside of the target neighbourhood
            if cds_end < win_start or cds_start > win_end:
                continue

            # also exclude genes that overlap with the neighbourhood boundary
            if cds_start < win_start or cds_end > win_end:
                continue

            # set gene neighbourhood region to fresh coordinates in genbank, otherwise won't work well with Clinker
            new_loc = FeatureLocation(
                cds_start - win_start,
                cds_end - win_start,
                strand=feat.location.strand,
            )
        ######################## NOT CLINKER SAFE OPTION: ###############################
        else:
            # exclude genes outside of the target neighbourhood
            if cds_end < win_start or cds_start > win_end:
                continue

            # keep the original location coords and any genes that overlap with window boundaries
            new_loc = FeatureLocation(
                cds_start,
                cds_end,
                strand=feat.location.strand,
            )

        # keep the qualifiers and translation if present
        valid_feat = SeqFeature(
            location=new_loc, type="CDS", qualifiers=feat.qualifiers
        )
        neighbour_feats.append(valid_feat)

    # add the neighbour features (with new location coords) to the sliced genbank
    sliced_rec.features = neighbour_feats
    sliced_rec.annotations["molecule_type"] = full_rec.annotations.get(
        "molecule_type", "DNA"
    )
    # TODO: remove?
    # add annotations/metainfo to genbank file
    # genome_id = genbank_input.stem
    # sliced_rec.annotations["accession"] = genome_id
    # sliced_rec.annotations["source"] = genome_id
    # sliced_rec.annotations["comment"] = "Genome source: GlobDB r226"
    # sliced_rec.annotations["date"] = today
    # sliced_rec.annotations["organism"] = species_dict[genome_id]
    # sliced_rec.annotations["taxonomy"] = taxonomy_dict[genome_id]

    # ====================================
    # STEP 3. write extracted gbk to file

    # write output
    output_path = (
        Path(outdir) / f"{genbank_input.stem}___{target_gene}-genomic_region.gbk"
    )
    output_path.parent.mkdir(exist_ok=True, parents=True)
    SeqIO.write(sliced_rec, output_path, "genbank")

    # logging
    print(f"Sliced Genbank for: {target_gene}; written to {output_path}")


# =======================================================================
def process_input_table(
    input_list: Path,
    args: argparse.Namespace,
) -> tuple[list[Path], list[str], list[Path]]:
    """Reads input table and processes each field for input into slice_genbank(). Utility function

    Input list should have three tab-separated fields per line:

        col1: path/to/genbankfile.gbk
        col2: target gene ID
        col3: path/to/output/directory

    ---
    Args:
        input_list (Path): path to input_list.tsv

    Returns:
        input_paths (list[Path]): a list of paths to the genbank files
        input_targets (list[str]): a list of target_gene IDs
        input_outdirs (list[Path]): a list of paths to the output dirs
    """
    # init empty lists
    input_paths, input_targets, input_outdirs = [], [], []

    # read input list
    with open(input_list, "r") as in_handle:
        while line := in_handle.readline():
            # split line into fields
            fields = line.rstrip().split("\t")

            # extract field info
            path = Path(fields[0])
            target = fields[1]
            outdir = Path(fields[2])

            ########### NO OVERWRITE OPTION ################
            if args.no_overwrite is True:
                outpath = outdir / f"{path.stem}___{target}-genomic_region.gbk"
                if outpath.exists():
                    print(f"Skipping: output genbank exists: {outpath}")
                    continue

            # append to lists
            input_paths.append(path)
            input_targets.append(target)
            input_outdirs.append(outdir)

    return input_paths, input_targets, input_outdirs


# =======================================================================
def main() -> None:
    """Workflow:
    ---
    main
     └── process_input_table
     └── ProcessPoolExecutor
          └── slice_genbank
               └── find_target_location
    """
    # parse args
    args = parse_args()

    # get input fields from input table
    input_paths, input_targets, input_outdirs = process_input_table(
        input_list=args.input_list,
        args=args,
    )

    # # run core function in a regular for loop
    # for path, target, outdir in zip(input_paths, input_targets, input_outdirs):
    #     slice_genbank(
    #         genbank_input=path,
    #         target_gene=target,
    #         outdir=outdir,
    #         upstream=args.upstream,
    #         downstream=args.downstream,
    #         args=args,
    #     )

    ##################################
    # BATCH PROCESSING!
    ##################################

    # create partial func for mapping
    slice_genbank_partial = partial(
        slice_genbank,
        upstream=args.upstream,
        downstream=args.downstream,
        args=args,
    )
    # use ProcessPoolExecutor
    with ProcessPoolExecutor(max_workers=args.cpu) as exe:
        futures = [
            # use submit(), allows for passing multiple iterable args, unlike map()
            exe.submit(
                slice_genbank_partial,
                genbank_input=path,
                target_gene=target,
                outdir=outdir,
            )
            for path, target, outdir in zip(input_paths, input_targets, input_outdirs)
        ]
        # yield results
        results = [f.result() for f in futures]


if __name__ == "__main__":
    sys.exit(main())
