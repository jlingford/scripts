#!/usr/bin/env python3
"""
Plot PAE heatmap from AlphaFold 3 JSON output, with subunit boundary lines from CIF file.
"""

import sys
import json
import numpy as np
import pandas as pd
from pathlib import Path
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from matplotlib.ticker import FormatStrFormatter
from matplotlib import rcParams
import matplotlib.font_manager as fm
from Bio.PDB.MMCIFParser import MMCIFParser

# ===================================
# Font setup
arial_font = "/home/james/Downloads/arial.ttf"
arial_font_bold = "/home/james/Downloads/Arial Bold.ttf"
fm.fontManager.addfont(arial_font)
fm.fontManager.addfont(arial_font_bold)
rcParams["font.sans-serif"] = "Arial"
rcParams["font.family"] = "Arial"
rcParams["font.size"] = 10

# ===================================
# Inputs
if len(sys.argv) != 3:
    print("Usage: ./plot_pae_af3.py <pae.json> <model.cif>")
    sys.exit(1)

json_file = Path(sys.argv[1])
cif_file = Path(sys.argv[2])

# ===================================
# Load PAE matrix from AlphaFold 3 JSON
with open(json_file, "r") as f:
    data = json.load(f)

# Try different key layouts (AF3 JSONs are not standardized yet)
try:
    pae_matrix = np.array(data["pae"])
except KeyError:
    try:
        pae_matrix = np.array(data["model_info"][0]["pae"]["values"])
    except KeyError:
        sys.exit("❌ Could not find PAE matrix in JSON file. Check JSON structure.")

paedf = pd.DataFrame(pae_matrix)
data_max = np.max(paedf.values)
data_min = np.min(paedf.values)

# ===================================
# Parse subunit boundaries from CIF file
parser = MMCIFParser(QUIET=True)
structure = parser.get_structure("model", cif_file)

chain_lengths = {}
for chain in structure.get_chains():
    residues = [res for res in chain.get_residues() if "CA" in res]  # ignore HETATM
    chain_lengths[chain.id] = len(residues)

# Compute cumulative boundaries
boundaries = np.cumsum(list(chain_lengths.values()))[:-1]  # omit final end
chain_order = list(chain_lengths.keys())

print("Detected subunit boundaries:")
for c, l in chain_lengths.items():
    print(f"  Chain {c}: {l} residues")

# ===================================
# Plot setup
fig, ax = plt.subplots(1, 1, figsize=(5, 5))

# palette = sns.cubehelix_palette(start=0.5, rot=-0.5, as_cmap=True)
palette = sns.light_palette("#918edb", as_cmap=True, reverse=False)
# palette = "coolwarm"

# Heatmap
im = ax.imshow(
    paedf,
    cmap=palette,
    extent=[0, len(paedf), len(paedf), 0],
    aspect="equal",
)

# Colorbar
cbar = fig.colorbar(
    im,
    ax=ax,
    label="pAE (Å)",
    fraction=0.045,
    ticks=[data_min, 10, 20, data_max],
    location="right",
)
cbar.ax.yaxis.set_major_formatter(FormatStrFormatter("%.0f"))

# ===================================
# Draw subunit boundary lines
for pos in boundaries:
    ax.axhline(pos, color="black", lw=0.8, ls="-")
    ax.axvline(pos, color="black", lw=0.8, ls="-")

# Optional: label chains along axes
tick_positions = np.concatenate(([0], boundaries, [len(paedf)]))
tick_labels = [f"{chain_order[i]}" for i in range(len(chain_order))]
# ax.set_xticks((tick_positions[:-1] + tick_positions[1:]) / 2)
# ax.set_yticks((tick_positions[:-1] + tick_positions[1:]) / 2)
ax.set_xticks(tick_positions[1:])
ax.set_yticks(tick_positions[1:])
ax.set_xticklabels(tick_labels, rotation=-90)
ax.set_yticklabels(tick_labels)

# ===================================
# Axis formatting
ax.xaxis.set_major_formatter(FormatStrFormatter("%.0f"))
ax.yaxis.set_major_formatter(FormatStrFormatter("%.0f"))
ax.set_xlabel("Scored residue")
ax.set_ylabel("Aligned residue")
ax.spines["top"].set_visible(True)
ax.spines["right"].set_visible(True)

plt.tight_layout()

# ===================================
# Save and show
outpath = Path(f"./output/pae_plot_af3_{json_file.stem}.png")
outpath.parent.mkdir(exist_ok=True)
plt.savefig(outpath, format="png", dpi=300, bbox_inches="tight")
plt.show()
plt.close("all")
