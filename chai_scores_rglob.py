#!/usr/bin/env python3
"""
Small python script
"""

import numpy as np
import pandas as pd
from pathlib import Path


# init array
chai_ptms = []
chai_names = []

for file in Path(".").rglob("*_scores_0.npz"):
    # get file name
    name = file.stem.split("_scores")[0]
    chai_names.append(name)

    # load npy file
    # df = np.load("./GCA_001577715___155_plddt.npy")
    df = np.load(file)

    # return ptm from npz, which is under key "ptm"
    ptm = df["ptm"]

    # append to list, converting it to float then string
    chai_ptms.append(str(float(ptm)))


# combine both lists into one
combined_list = [list(x) for x in zip(chai_names, chai_ptms)]

# load combined list into numpy
arr = np.array(combined_list)

# save array as tsv
np.savetxt(
    "chai_ptms.tsv",
    arr,
    delimiter="\t",
    fmt="%s",  # str format needed
)
