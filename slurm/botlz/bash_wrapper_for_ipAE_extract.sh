#!/usr/bin/bash

for dir in ./example_run/*; do
    # cd "$dir" || exit
    ./ipAE_extract.py \
        --cif ${dir}/*0.cif \
        --pae ${dir}/pae*0.npz
done
