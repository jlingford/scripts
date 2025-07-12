#!/usr/bin/env bash

# USAGE:
# jupynote.sh [TITLE]

# DESCRIPTION: quickly create .qmd notebook for jupyter lab like work

# take first command line argument
TITLE=$1

# find file with highest num prefix in current dir, return just the num
HIGHEST_NUM=$(fd -d1 "^[0-9]+" | tail -n 1 | sed -E 's/^([0-9]+)[_-].*/\1/')

# if no previous file, set number prefix to 00
if [[ -z $HIGHEST_NUM ]]; then
    HIGHEST_NUM="00"
fi

# increment for next number
NEXT_NUM=$((HIGHEST_NUM + 1))

# set new prefix for new file (requires printf for leading zeros)
FILE_PREFIX=$(printf "%02d" ${NEXT_NUM})

# set filename
FILENAME="${FILE_PREFIX}-${TITLE}-$(date -u +%Y%m%d).qmd"

# create new file
touch "${FILENAME}"

echo "---
title: '${TITLE}'
author: 'James Lingford'
date: '$(date -u +%Y-%m-%d)'
toc: true
format:
    html:
        code-tools: true
        code-fold: true
        code-summary: 'Show code'
        code-copy: true
        html-math-method: katex
        embed-resources: true
        theme:
            light: default
            dark: darkly
jupyter: python3
---

## Introduction

Aim: description

\`\`\`{python}
# import libraries
from Bio import SeqIO
import statistics as stat
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
\`\`\`


\`\`\`{python}

\`\`\`

" >>${FILENAME}
