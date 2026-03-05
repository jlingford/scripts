#!/usr/bin/env python3
"""
Take pae*.npz file from Boltz run and return pAE plot.

Works only for a single .npz file. doesn't do anything else fancy
"""

from Bio.PDB.MMCIFParser import MMCIFParser
from matplotlib import rcParams
from matplotlib.ticker import FormatStrFormatter
from pathlib import Path
import json
import matplotlib.font_manager as fm
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
import pandas as pd
import seaborn as sns
import sys

# ===================================

# set font
arial_font = "/home/james/Downloads/arial.ttf"
arial_font_bold = "/home/james/Downloads/Arial Bold.ttf"
fm.fontManager.addfont(arial_font)
fm.fontManager.addfont(arial_font_bold)
rcParams["font.sans-serif"] = "Arial"
rcParams["font.family"] = "Arial"
rcParams["font.size"] = 10

# ===================================

pae_file = Path(sys.argv[1])
cif_file = Path(sys.argv[2])

# ===================================

# load pae, plddt, and image data
pae = np.load(pae_file)
paedf = pd.DataFrame(
    pae["pae"]
)  # boltz pae data is stored under the key "pae" in npz datafile
data_max = np.max(pae["pae"])
data_min = np.min(pae["pae"])
data_med = (data_min + data_max) / 2
# load ptm and iptm scores
# scores = np.load(score)

# add protein name from file.stem to add to left of figure
# file.stem = score.stem
# file.stem = file.stem.replace("_scores_0", "")
# file.stem = re.sub(r"_0$", "", file.stem)

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
# set figure
fig, ax = plt.subplots(
    1,
    1,
    # figsize=(10, 10),
    figsize=(5, 5),
)

# set heatmap colorscheme
palette = sns.light_palette("#918edb", as_cmap=True, reverse=False)
# palette = "coolwarm"

# add pae heatmap
im = ax.imshow(
    paedf,
    cmap=palette,
    extent=[0, len(paedf), len(paedf), 0],
    aspect="equal",
)
# add colorbar to pae heatmap
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
outpath = Path(f"./output/pae_plot_boltz_{cif_file.stem}.png")
outpath.parent.mkdir(exist_ok=True)
plt.savefig(outpath, format="png", dpi=300, bbox_inches="tight")
plt.show()
plt.close("all")


# ax.xaxis.set_major_locator(ticker.LinearLocator(5))
# ax.yaxis.set_major_locator(ticker.LinearLocator(5))
# ax.yaxis.set_major_formatter(FormatStrFormatter("%.0f"))
# ax.xaxis.set_major_formatter(FormatStrFormatter("%.0f"))
# ax.set_xlabel("Scored residue")
# ax.set_ylabel("Aligned residue")
# ax.spines["top"].set_visible(False)
# ax.spines["right"].set_visible(False)
#
# # # add text of protein name to left of figure
# # fig.text(
# #     0.05,
# #     0.5,
# #     file.stem,
# #     rotation=90,
# #     verticalalignment="center",
# #     horizontalalignment="center",
# #     fontsize=12,
# #     fontweight="normal",
# #     # bbox=dict(boxstyle="round,pad=0.5", facecolor='lightgrey', edgecolor='lightgrey', alpha=0.8)
# # )
#
# # # make plddt legend with colored circles
# # legend_elements = [
# #     Line2D(
# #         [0],
# #         [0],
# #         marker="o",
# #         color="w",
# #         markerfacecolor="#1e66f5",
# #         markersize=14,
# #         label="[100, 90)",
# #     ),
# #     Line2D(
# #         [0],
# #         [0],
# #         marker="o",
# #         color="w",
# #         markerfacecolor="#04a5e5",
# #         markersize=14,
# #         label="[90, 70)",
# #     ),
# #     Line2D(
# #         [0],
# #         [0],
# #         marker="o",
# #         color="w",
# #         markerfacecolor="#f8e1ae",
# #         markersize=14,
# #         label="[70, 50)",
# #     ),
# #     Line2D(
# #         [0],
# #         [0],
# #         marker="o",
# #         color="w",
# #         markerfacecolor="#f9b286",
# #         markersize=14,
# #         label="[50, 0]",
# #     ),
# # ]
# # # add plddt legend
# # ax[0].legend(
# #     handles=legend_elements,
# #     title="pLDDT",
# #     alignment="center",
# #     loc="upper center",
# #     frameon=False,
# #     fancybox=False,
# #     shadow=False,
# #     ncol=4,
# #     bbox_to_anchor=(0.5, 1.15),
# # )
#
# # # format ptm and iptm numbers into a string if they're more than 0
# # ptm = scores["ptm"]
# # iptm = scores["iptm"]
# # ptm = ptm[0] if ptm[0] > 0 else "n/a"
# # iptm = iptm[0] if iptm[0] > 0 else "n/a"
# # ptm_formatted = f"{ptm:.2f}" if isinstance(ptm, (int, float, np.number)) else ptm
# # iptm_formatted = f"{iptm:.2f}" if isinstance(iptm, (int, float, np.number)) else iptm
# # # print ptm and iptm text
# # ptm_text = f"pTM = {ptm_formatted}        ipTM = {iptm_formatted}"
# # # put ptm and iptm label on figure
# # fig.text(
# #     0.71,
# #     0.890,
# #     ptm_text,
# #     rotation=0,
# #     verticalalignment="center",
# #     horizontalalignment="center",
# #     fontsize=12,
# #     fontweight="normal",
# # )
#
# # create output dir
# # outdir = Path("./output_plots")
# # outdir.mkdir(parents=True, exist_ok=True)
#
# # save figures
# # plt.savefig(
# #     f"{outdir}/{file.stem}_summary_plot.svg",
# #     format="svg",
# #     dpi=300,
# #     bbox_inches="tight",
# # )
#
# plt.tight_layout()
#
# plt.savefig(
#     f"./pae_plot_boltz_{file.stem}.png",
#     format="png",
#     dpi=300,
#     bbox_inches="tight",
# )
# # be sure to close plot each time to avoid consuming lots of memory
# plt.show()
# plt.close("all")
