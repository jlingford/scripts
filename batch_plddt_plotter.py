#!/usr/bin/env python3

import numpy as np
import re
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import seaborn as sns
import matplotlib.ticker as ticker
from matplotlib.ticker import FormatStrFormatter

# load data
p = Path(".")
png_files = sorted(list(p.rglob("*_0.png")))
pae_files = sorted(list(p.rglob("*_pae.npy")))
score_files = sorted(list(p.rglob("*_0.npz")))


def make_plot(png, pae, score):
    # load pae, plddt, and image data
    img = plt.imread(png, "png")
    pae = np.load(pae)
    paedf = pd.DataFrame(pae[0])
    data_max = np.max(pae[0])
    # load ptm and iptm scores
    scores = np.load(score)

    # add protein name from filename to add to left of figure
    filename = score.stem
    filename = filename.replace("_scores_0", "")
    filename = re.sub(r"_0$", "", filename)

    # set figure
    fig, ax = plt.subplots(1, 2, figsize=(12, 6))

    # add png of plddt
    ax[0].imshow(img)
    ax[0].set_axis_off()

    # set heatmap colorscheme
    purp = sns.light_palette("#918edb", as_cmap=True, reverse=False)

    # add pae heatmap
    im = ax[1].imshow(
        paedf, cmap=purp, extent=[0, len(paedf), len(paedf), 0], aspect="equal"
    )
    # add colorbar to pae heatmap
    cbar = fig.colorbar(
        im,
        ax=ax[1],
        label="Predicted Aligned Error (Å)",
        fraction=0.045,
        ticks=[0, data_max],
        location="right",
    )
    # change heatmap and colorbar tick and axis settings
    cbar.set_ticks([0, data_max])
    cbar.ax.yaxis.set_major_formatter(FormatStrFormatter("%.0f"))
    ax[1].xaxis.set_major_locator(ticker.LinearLocator(5))
    ax[1].yaxis.set_major_locator(ticker.LinearLocator(5))
    ax[1].yaxis.set_major_formatter(FormatStrFormatter("%.0f"))
    ax[1].xaxis.set_major_formatter(FormatStrFormatter("%.0f"))
    ax[1].set_xlabel("Scored residue")
    ax[1].set_ylabel("Aligned residue")
    ax[1].spines["top"].set_visible(False)
    ax[1].spines["right"].set_visible(False)

    # add text of protein name to left of figure
    fig.text(
        0.05,
        0.5,
        filename,
        rotation=90,
        verticalalignment="center",
        horizontalalignment="center",
        fontsize=12,
        fontweight="normal",
        # bbox=dict(boxstyle="round,pad=0.5", facecolor='lightgrey', edgecolor='lightgrey', alpha=0.8)
    )

    # make plddt legend with colored circles
    legend_elements = [
        Line2D(
            [0],
            [0],
            marker="o",
            color="w",
            markerfacecolor="#1e66f5",
            markersize=14,
            label="[100, 90)",
        ),
        Line2D(
            [0],
            [0],
            marker="o",
            color="w",
            markerfacecolor="#04a5e5",
            markersize=14,
            label="[90, 70)",
        ),
        Line2D(
            [0],
            [0],
            marker="o",
            color="w",
            markerfacecolor="#f8e1ae",
            markersize=14,
            label="[70, 50)",
        ),
        Line2D(
            [0],
            [0],
            marker="o",
            color="w",
            markerfacecolor="#f9b286",
            markersize=14,
            label="[50, 0]",
        ),
    ]
    # add plddt legend
    ax[0].legend(
        handles=legend_elements,
        title="pLDDT",
        alignment="center",
        loc="upper center",
        frameon=False,
        fancybox=False,
        shadow=False,
        ncol=4,
        bbox_to_anchor=(0.5, 1.15),
    )

    # format ptm and iptm numbers into a string if they're more than 0
    ptm = scores["ptm"]
    iptm = scores["iptm"]
    ptm = ptm[0] if ptm[0] > 0 else "n/a"
    iptm = iptm[0] if iptm[0] > 0 else "n/a"
    ptm_formatted = f"{ptm:.2f}" if isinstance(ptm, (int, float, np.number)) else ptm
    iptm_formatted = (
        f"{iptm:.2f}" if isinstance(iptm, (int, float, np.number)) else iptm
    )
    # print ptm and iptm text
    ptm_text = f"pTM = {ptm_formatted}        ipTM = {iptm_formatted}"
    # put ptm and iptm label on figure
    fig.text(
        0.71,
        0.890,
        ptm_text,
        rotation=0,
        verticalalignment="center",
        horizontalalignment="center",
        fontsize=12,
        fontweight="normal",
    )

    # create output dir
    outdir = Path("./output_plots")
    outdir.mkdir(parents=True, exist_ok=True)

    # save figures
    # plt.savefig(
    #     f"{outdir}/{filename}_summary_plot.svg",
    #     format="svg",
    #     dpi=300,
    #     bbox_inches="tight",
    # )
    plt.savefig(
        f"{outdir}/{filename}_summary_plot.png",
        format="png",
        dpi=300,
        bbox_inches="tight",
    )
    # be sure to close plot each time to avoid consuming lots of memory
    plt.close("all")


for png, pae, score in zip(png_files, pae_files, score_files):
    print("=== Saving plot ===")
    print(f"png file = {png.name} in dir: {png}")
    print(f"pae file = {pae.name} in dir: {pae}")
    print(f"npz file = {score.name} in dir: {score}")
    make_plot(png, pae, score)
