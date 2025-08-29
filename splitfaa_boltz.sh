#!/bin/bash

# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Error: must provide one argument"
    echo "Usage: $(basename $0) [INPUT.fasta]"
    exit 1
fi

# WARN: multi-fasta file and a3m dir name have to share the same name

# take input fasta
input_file="$1"

# create output_dir
output_dir=${input_file%.*}
file_name=${output_dir##*/}
mkdir -p "${output_dir}"

# awk funciton to split fastas
awk -v outdir="${output_dir}" '
  BEGIN {
    prev_seqname = ""
  }
  /^>/{
    split($1, arr, ">")
    seqname = arr[2]
    gsub(/[\.\|]/, "_", seqname)
    gsub(/[#%^\*\\+!={}?]/, "", seqname)
    if (seqname != prev_seqname && outfile) {
      close(outfile)
    }
    outfile = outdir "/" seqname ".fasta"
    prev_seqname = seqname
  }
  {
    print $0 >> outfile
  }
' "${input_file}"

# rename the fasta headers for boltz input
for file in "${output_dir}"/*.fasta; do
    name=${file##*/}
    name=${name%%.*}

    sed -i "s#^>.*#>A|protein|./msas/fefe_msas/${name}.a3m#" "${file}"

done

# mv *.faa ${output_dir}
# mv ${output_dir}/${input_file} .
