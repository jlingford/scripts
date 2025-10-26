#!/usr/bin/env python3
"""
Return .tsv of average pLDDT scores (top models only) for Chai-1 models
"""

import numpy as np
import pandas as pd
from pathlib import Path


# init array
chai_plddts = []
chai_names = []

for file in Path(".").rglob("*_plddt.npy"):
    # get file name
    name = file.stem.split("_plddt")[0]
    chai_names.append(name)

    # load npy file
    # df = np.load("./GCA_001577715___155_plddt.npy")
    df = np.load(file)

    # find average of each row (each row is one of the 5 models)
    av = np.average(df, axis=1)

    # return largest of the 5 averages
    top = np.amax(av)

    # append to list, converting it to float then string
    chai_plddts.append(str(float(top)))


# combine both lists into one
combined_list = [list(x) for x in zip(chai_names, chai_plddts)]

# load combined list into numpy
arr = np.array(combined_list)

# save array as tsv
np.savetxt(
    "chai_plddts.tsv",
    arr,
    delimiter="\t",
    fmt="%s",  # str format needed
)
