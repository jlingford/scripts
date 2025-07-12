#!/usr/bin/bash

filename=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: $(basename $0) [NEW_FILE_NAME]"
    exit 1
fi

touch ${filename}.sh
chmod u+x ${filename}.sh

# Guts of template
template() {
    cat <<'EOF'
#!/usr/bin/bash

#--------------------------------------------------------------------#
# Defining usage
#--------------------------------------------------------------------#
usage() {
    echo "
# --------------------------------------#
#          $(basename $0) help doc
# --------------------------------------#
Usage: $0 -i INPUT -o OUTPUT [OPTIONS]

Required params:
    -i, --input STR      Path to input file
    -o, --output STR     Path to output file

Optional params:

Info:
    -h, --help           Print help
"
}

#--------------------------------------------------------------------#
# Defining getop params
#--------------------------------------------------------------------#
# create command line options with getopt
opt_short="i:o:h"
opt_long="input:,output:,help"
OPTS=$(getopt -o "$opt_short" --long "$opt_long" -n 'parse-options' -- "$@")

# If wrong option is given, print error message.
if [[ $? -ne 0 ]]; then
    echo "Error: Wrong input parameter used!"
    usage
    exit 1
fi

# eval getopt opts for while loop
eval set -- "$OPTS"

# Parsing getopt parameters
while true; do
    case "$1" in
    -i | --input)
        input="$2"
        shift 2
        ;;
    -o | --output)
        output="$2"
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

#--------------------------------------------------------------------#
# Set defaults and constants
#--------------------------------------------------------------------#
input=${input:-""}
output=${output:-""}
threads=${threads:-1}

#--------------------------------------------------------------------#
# Validate inputs and program availablity
#--------------------------------------------------------------------#
# Check required params are provided
if [[ -z "$input" ]] || [[ -z "$output" ]]; then
    echo "Error: Required arguments are missing."
    usage
    exit 1
fi

# Make sure all input files exist
if [[ $input != "" ]] && [[ ! -d "$input" && ! -f "$input" ]]; then
    echo "Input ${input} not detected."
    exit 1
fi

# Make sure required programs are available. e.g.:
# if ! command -v foldseek; then
#     echo "foldseek not detected!"
#     exit 1
# fi

#--------------------------------------------------------------------#
# Main
#--------------------------------------------------------------------#
echo "$0 inputs:
INPUT: $input
OUTPUT: $output

"

echo "$0: Started at $(date)"
echo ""

# Make directories if necessary
mkdir -p $(dirname ${output})

### WORK GOES HERE...

# Fin
echo ""
echo "$0: Finished at $(date)"
EOF
}

template >"${filename}.sh"
