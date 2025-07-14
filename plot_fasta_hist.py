#!/usr/bin/env python3

import argparse
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.ticker import StrMethodFormatter
from Bio import SeqIO
import seaborn as sns
import sys

# get positional argument input
input_file = sys.argv[1]
p = Path(sys.argv[1])
title = p.stem


# plot histograms
def plot_hist(file, title):
    """
    Plot histogram of fasta file length distribution
    """
    fig, ax = plt.subplots(figsize=(6, 4))
    seq_lengths = [len(record.seq) for record in SeqIO.parse(file, "fasta")]
    sns.histplot(data=seq_lengths, ax=ax, bins=100, color="coral")
    # ax.hist(seq_lengths, bins=100)
    ax.set_title(title)
    # ax.set_xlim(0, 1500)
    ax.set_ylabel("count")
    ax.set_xlabel("sequence length [aa]")
    ax.yaxis.set_major_formatter(StrMethodFormatter("{x:,.0f}"))
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    plt.tight_layout()
    plt.savefig(f"{title}.png", format="png", dpi=300)
    plt.show()


plot_hist(input_file, title)
