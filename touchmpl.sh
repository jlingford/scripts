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
Small python script
"""

import argparse
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
from matplotlib import rcParams
import matplotlib.font_manager as fm
import matplotlib.ticker as ticker
from matplotlib.ticker import FormatStrFormatter


# parse cli args
parser = argparse.ArgumentParser()
parser.add_argument("input", help="Input data file", type=Path)
args = parser.parse_args()

# set font
arial_font = "/home/james/Downloads/arial.ttf"
arial_font_bold = "/home/james/Downloads/Arial Bold.ttf"
fm.fontManager.addfont(arial_font)
fm.fontManager.addfont(arial_font_bold)
rcParams["font.sans-serif"] = "Arial"
rcParams["font.family"] = "Arial"
rcParams["font.size"] = 10


def custom_plot(inputfile, filename):
    """Plot"""

    # write plot
    plt.savefig(
        f"./{name}_summary_plot.png",
        format="png",
        dpi=100,
        bbox_inches="tight",
    )
    plt.show()
    plt.close("all")


custom_plot(args.input, args.input.stem)
EOF
}

template >"${filename}.py"
