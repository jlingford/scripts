#!/usr/bin/bash

input=$1

if [[ $# -eq 0 ]]; then
    >&2 echo "Error: no arguments provided"
    >&2 echo "USAGE: faa2af3json.sh [FASTA_INPUT]"
    >&2 echo "Note: requires faa2tsv.sh as a dependency"
    exit 1
fi

faa2tsv.sh ${input} |
    sed 's/*//' |
    sed 's/~/_/' |
    sed 's/\./_/g' |
    awk '
    BEGIN{
        printf"[\n"
    }
    {
        printf"\t{\n\t\t\"name\": \"%s\",\n\t\t\"modelSeeds\": [],\n\t\t\"sequences\": [\n\t\t\t{\n\t\t\t\t\"proteinChain\": {\n\t\t\t\t\t\"sequence\": \"%s\",\n\t\t\t\t\t\"count\": 1\n\t\t\t\t}\n\t\t\t}\n\t\t],\n\t\t\"dialect\": \"alphafoldserver\",\n\t\t\"version\": 1\n\t},\n", $1, $2;
    }
    END{
        printf"]\n"
    }
'
