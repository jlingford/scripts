# BASH file manipulation
# splitting .tsv cluster output into separate fasta files

#usage: tsv2splitfastas.sh <input.tsv>
INPUT_TSV=$1
N=10

if [[ ! -d ./${INPUT_TSV}-splitfaa ]]; then
    mkdir -p ./${INPUT_TSV}-splitfaa
    echo "made output dir"
fi

echo "splitting fastas now..."

# split tsv into separate fasta files based on shared cluster name ($1)
awk -F'\t' '
NR>1{
        gsub(/[^a-zA-Z0-9]/, "-", $1)
        printf ">%s\n%s\n", $2,$NF > $1
    }
}' ${INPUT_TSV}

echo "renaming fastas..."

# rename file with number of fastas in headers
for file in *.faa; do
    COUNT=$(grep -c "^>" ${file})
    perl-rename "s/^/${COUNT}-seqsincluster-/" ${file}
done

# keep the top N number of split fasta file clusters, and remove the rest
ls -la | grep .faa | awk '{print $NF}' | sort -gr | tail -n+$((${N} + 1)) | xargs rm

mv *.faa ./${INPUT_TSV}-splitfaa

echo "done"
