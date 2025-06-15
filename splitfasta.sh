#!/bin/bash

# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 input.fasta"
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
