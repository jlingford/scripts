#!/usr/bin/env python
"""
Find mean and median pAE and i_pAE scores for a multimer from Boltz.
Requires input of the Boltz pae*.npz file and .cif file.
Default interface size of 5 angstrom.

function calls:
main()
 |_ parse_arguments()
 |_ compute_interface_pae()
    |_ get_chain_offsets()
    |_ get_interface_residues()
"""

import argparse
from os import sep
import numpy as np
import pandas as pd
from Bio.PDB import MMCIFParser
from itertools import combinations
from pathlib import Path


def parse_arguments() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Compute mean/median interface pAE per chain-pair (with and without distance cutoff)."
    )
    parser.add_argument(
        "-p",
        "--pae",
        type=Path,
        required=True,
        help="Path to PAE matrix (.npy)",
    )
    parser.add_argument(
        "-c",
        "--cif",
        type=Path,
        required=True,
        help="Path to AlphaFold multimer .cif file",
    )
    parser.add_argument(
        "--cutoff",
        type=float,
        default=5.0,
        required=False,
        help="Distance cutoff in Å (default: 5.0)",
    )
    # parser.add_argument(
    #     "-o",
    #     "--out",
    #     required=False,
    #     help="Optional .tsv file for per-chain results",
    # )

    args = parser.parse_args()

    return args


def get_chain_offsets(structure) -> dict:
    """Return residue count offsets for each chain in the PAE matrix."""
    offsets = {}
    offset = 0
    for chain in structure[0]:
        n_res = len([r for r in chain.get_residues() if r.has_id("CA")])
        offsets[chain.id] = (offset, offset + n_res)
        offset += n_res
    return offsets


def get_interface_residues(structure, chain1_id, chain2_id, cutoff=5.0) -> set:
    """Return residue indices from two chains that are within cutoff."""
    chain1 = structure[0][chain1_id]
    chain2 = structure[0][chain2_id]

    interface_res1, interface_res2 = set(), set()

    for res1 in chain1:
        if not res1.has_id("CA"):
            continue
        for res2 in chain2:
            if not res2.has_id("CA"):
                continue
            if res1["CA"] - res2["CA"] <= cutoff:
                interface_res1.add(res1.id[1] - 1)
                interface_res2.add(res2.id[1] - 1)

    # print(type(interface_res1))
    return interface_res1, interface_res2


def compute_interface_pae(
    args,
    pae_matrix,
    structure,
) -> pd.DataFrame:
    """Compute interface pAE (mean, median) per chain pair with and without cutoff."""
    chain_ids = [c.id for c in structure[0]]
    chain_offsets = get_chain_offsets(structure)
    cutoff = args.cutoff

    records = []

    for chain1_id, chain2_id in combinations(chain_ids, 2):
        offset1_start, offset1_end = chain_offsets[chain1_id]
        offset2_start, offset2_end = chain_offsets[chain2_id]

        # extract submatrix between chain1 and chain2
        submatrix = pae_matrix[offset1_start:offset1_end, offset2_start:offset2_end]
        submatrix_T = pae_matrix[offset2_start:offset2_end, offset1_start:offset1_end]
        combined = np.concatenate([submatrix.flatten(), submatrix_T.flatten()])

        # compute mean/median without cutoff
        mean_full = np.mean(combined)
        median_full = np.median(combined)

        # get contact residues (cutoff-based)
        res1_set, res2_set = get_interface_residues(
            structure, chain1_id, chain2_id, cutoff=cutoff
        )
        # compute mean/median WITH cutoff
        cutoff_values = []
        if res1_set and res2_set:
            for i in res1_set:
                for j in res2_set:
                    cutoff_values.append(
                        pae_matrix[offset1_start + i, offset2_start + j]
                    )
                    cutoff_values.append(
                        pae_matrix[offset2_start + j, offset1_start + i]
                    )

        # compute mean/median with cutoff (if any)
        mean_cutoff = np.mean(cutoff_values) if cutoff_values else np.nan
        median_cutoff = np.median(cutoff_values) if cutoff_values else np.nan

        records.append(
            {
                "ID": args.cif.stem,
                "chain1": chain1_id,
                "chain2": chain2_id,
                "mean_i_pAE_full": mean_full,
                "median_i_pAE_full": median_full,
                "mean_i_pAE_cutoff": mean_cutoff,
                "median_i_pAE_cutoff": median_cutoff,
                "res_pairs_within_i_pAE_cutoff": len(cutoff_values),
                "cutoff_used_in_angstrom": cutoff,
            }
        )

    df = pd.DataFrame(records)

    return df


def main() -> None:
    args = parse_arguments()

    # Load inputs
    pae = np.load(args.pae)
    pae = pae["pae"]
    structure = MMCIFParser(QUIET=True).get_structure("model", args.cif)

    df = compute_interface_pae(args, pae, structure)

    df.to_csv(f"{args.cif.with_suffix('')}_ipAE.tsv", index=False, sep="\t")


if __name__ == "__main__":
    main()
