#!/bin/bash

# Check if the input file is provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: must provide two arguments"
    echo "Usage: $(basename $0) [INPUT.fasta] [OUTDIR_NAME]"
    exit 1
fi

input_file="$1"
output_dir="$2"

if [[ ! -d $output_dir ]]; then
    mkdir -p "${output_dir}"
fi

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
    outfile = outdir "/" seqname ".faa"
    prev_seqname = seqname
  }
  {
    print $0 >> outfile
  }
' "${input_file}"

# mv *.faa ${output_dir}
# mv ${output_dir}/${input_file} .
