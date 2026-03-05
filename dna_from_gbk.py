#!/usr/bin/env python3

import argparse
from Bio import SeqIO
from pathlib import Path


DESCRIPTION = """
Extract DNA sequence from GenBank file given a gene ID.\n
Prints a tsv to stdout in the form of: GENE_ID<tab>DNA_SEQ
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument(
        "-i",
        "--gene_id",
        dest="gene_id",
        type=str,
        metavar="GENE_ID",
        help="Gene ID of CDS in Genbank file [type: str]",
    )

    parser.add_argument(
        "-g",
        "--gbk_file",
        dest="gbk_file",
        type=Path,
        metavar="GENBANK_FILE",
        help="Path to GenBank file [type: path]",
    )

    args = parser.parse_args()

    if args.gene_id is None:
        parser.error("None")
    if args.gbk_file is None:
        parser.error("None")

    return args


def extract_dna_from_genbank(
    target_gene_id: str,
    gbk_file: Path,
) -> None:
    """
    Function to extract DNA sequence of a gene ID from genbank file/
    Uses the in-built Biopython method `feat.extract(rec.seq)` to do the heavy lifting
    Prints gene_id and dna_seq to stdout in tsv format
    """

    for rec in SeqIO.parse(gbk_file, "genbank"):
        # loop over genbank features to get to target_gene_id
        for feat in rec.features:
            # check that it's a CDS
            if feat.type == "CDS":
                # print(feat)
                gene_name = feat.qualifiers.get("locus_tag", [0])[0]
                # faa_seq = feat.qualifiers.get("translation", [0])[0]
                # print(gene_name)
                if target_gene_id == gene_name:
                    # print(gene_name)
                    dna_seq = feat.extract(rec.seq)
                    # print(dna_seq)
                    # trans_seq = feat.translate(rec.seq)
                    # print(trans_seq)
                    print(f"{gene_name}\t{dna_seq}")


def main():
    args = parse_args()
    extract_dna_from_genbank(
        target_gene_id=args.gene_id,
        gbk_file=args.gbk_file,
    )


if __name__ == "__main__":
    main()
