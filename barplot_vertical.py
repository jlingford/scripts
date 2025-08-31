#!/usr/bin/env python3
"""
Plot a vertical standing barplot. requires modification
"""

import sys
import numpy as np
import polars as pl
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib import rcParams
import matplotlib.font_manager as fm


# set font
arial_font = "/home/james/Downloads/arial.ttf"
arial_font_bold = "/home/james/Downloads/Arial Bold.ttf"
fm.fontManager.addfont(arial_font)
fm.fontManager.addfont(arial_font_bold)
rcParams["font.sans-serif"] = "Arial"
rcParams["font.family"] = "Arial"
rcParams["font.size"] = 10

# import table
file = sys.argv[1]
# file = "./nife_boltz_covm00_id70_cifs_clusterslist.tsv"

df = pl.read_csv(
    file,
    separator="\t",
    has_header=False,
    new_columns=["cluster_rep", "count"],
)

y = "cluster_rep"
x = "count"

# plot barplot
fig, ax = plt.subplots(figsize=(6, 8))

ax = sns.barplot(
    df,
    x=x,
    y=y,
    linewidth=1,
    # color="darkgrey",
    # color="lightskyblue",
    color="#81c8be",
    # color="#ef9f76",
    edgecolor="black",
    alpha=1.0,
)

# add numbers to each bar
# ax.bar_label(ax.containers[0], padding=6)

for bar in ax.patches:
    width = bar.get_width()
    ypos = bar.get_y() + bar.get_height() / 2
    # make bar labels with comma separated integers
    label = f"{width:,.0f}"

    pad = 100
    if width > 3000:
        ax.text(
            width - pad,
            ypos,
            label,
            va="center",
            ha="right",
            color="whitesmoke",
            fontweight="bold",
        )
    else:
        ax.text(width + pad, ypos, label, va="center", ha="left", color="black")
# else:
# ax.bar_label(ax.containers[0], padding=6)
#     ax.text(width + 1, ypos, label, va="center", ha="right", color="black")


# remove top and right spines, and trim spines
sns.despine(offset=5, trim=True)

# change spine and axis positions
ax.tick_params(axis="y", length=0)
ax.spines["left"].set_visible(False)
ax.spines["bottom"].set_visible(True)
ax.spines["bottom"].set_position(("outward", 5))
ax.xaxis.set_label_position("bottom")

# set title and axis labels
plt.suptitle(
    "[NiFe] LSU proteins clustered by structural similarity", fontsize=10, y=1.000
)
ax.set_ylabel("Cluster represetative i.d.", labelpad=15, fontsize=10)
ax.set_xlabel("Clustered proteins", labelpad=8, fontsize=10)

# set number of ticks
ax.tick_params(axis="x", rotation=90)
t = np.arange(0, 3501, 1000)
ax.set_xticks(ticks=t, minor=False)
# ax.set_xticks([0, 500, 1500, 2500, 3500], minor=False)

# plot
plt.tight_layout()

plt.savefig("./barplot.png", format="png", dpi=300)

plt.show()
