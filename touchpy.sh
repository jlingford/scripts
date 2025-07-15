#!/usr/bin/bash

filename=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: $(basename $0) [NEW_FILE_NAME]"
    exit 1
fi

touch ${filename}.sh
chmod u+x ${filename}.sh

template() {
    cat <<'EOF'
#!/usr/bin/env python3
"""
Small python script
"""

import os
import re
import sys
import shutil
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from Bio import SeqIO
from pathlib import Path


# Stuff...

EOF
}

template >"${filename}.sh"
