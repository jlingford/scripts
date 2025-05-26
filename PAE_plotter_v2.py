#!/usr/bin/env python3
"""
Plot PAE from alphafold .json files
"""

import json
import argparse
from pathlib import Path
import matplotlib.pyplot as plt


# accept one positional argument (the input file)
parser = argparse.ArgumentParser(
    description="generate PAE plot from AlphaFold3 .json file"
)
parser.add_argument(
    "input",
    metavar="FILE",
    type=argparse.FileType("r"),
    help="provide a path/to/file.faa",
)
args = parser.parse_args()


# enter  path to file
json_file = "scrapbook/example_pae.json"
file_name = Path(json_file).stem

with open(json_file) as f:
    data = json.load(f)

# For AlphaFold2 ColabFold json files
# pae = data["predicted_aligned_error"]

# For AlphaFold3 json files
pae = data["pae"]

# set subplots
fig = plt.figure()
fig, ax = plt.subplots()

# create heatmap
im = ax.imshow(pae, cmap="Greens_r", vmin=0, aspect="equal")

# configure colour bar
fig.colorbar(im, ax=ax, label="Predicted Aligned Error (Å)")

# labels
ax.set_xlabel("Scored residue")
ax.set_ylabel("Aligned residue")

# move x axis to top
ax.tick_params(top=True, labeltop=True, bottom=False, labelbottom=False)
ax.xaxis.set_label_position("top")

# make tick numbers equal on each axis
ax.set_xticks(range(0, len(pae), 100))
ax.set_yticks(range(0, len(pae), 100))

# ax.set_xticks(range(0, len(pae), len(pae) - 1))
# ax.set_yticks(range(0, len(pae), len(pae) - 1))

# ax.set_xticks([])
# ax.set_yticks([])

# saving figures
plt.savefig(f"{file_name}.png", format="png", dpi=300, transparent=True)
plt.close()
