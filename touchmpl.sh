#!/usr/bin/bash

filename=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: $(basename $0) [NEW_FILE_NAME]"
    exit 1
fi

touch ${filename}.py
chmod u+x ${filename}.py

template() {
    cat <<'EOF'
#!/usr/bin/env python3
"""
Small python script to plot something
"""

import sys
import argparse
import numpy as np
import pandas as pd
import polars as pl
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
from matplotlib import rcParams
import matplotlib.font_manager as fm
import matplotlib.ticker as ticker
from matplotlib.ticker import FormatStrFormatter


#=============================================
# set font
arial_font = "/home/james/Downloads/arial.ttf"
arial_font_bold = "/home/james/Downloads/Arial Bold.ttf"
fm.fontManager.addfont(arial_font)
fm.fontManager.addfont(arial_font_bold)
rcParams["font.sans-serif"] = "Arial"
rcParams["font.family"] = "Arial"
rcParams["font.size"] = 10

#=============================================
# parse cli args
parser = argparse.ArgumentParser()
parser.add_argument("input", help="Input data file", type=Path)
args = parser.parse_args()

# or import from sys
file = Path(sys.argv[1])

#=============================================
# uses argparse to take input

def custom_plot(file, filename):
    """Plot"""

    # read data
    df = pl.read_csv(
        file,
        separator="\t",
        has_header=False,
        new_columns=["col1", "col2"]
    )
    print(df)

    # make plot
    fig, ax = plt.subplots(figsize=(5,5))

    # write plot
    plt.savefig(
        f"./plot_{filename}.png",
        format="png",
        dpi=300,
        bbox_inches="tight",
    )
    plt.tight_layout()
    plt.show()
    plt.close("all")


custom_plot(args.input, args.input.stem)
EOF
}

template >"${filename}.py"
