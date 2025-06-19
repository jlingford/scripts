#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J NR_setup
#SBATCH --mem=367000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --account=rp24
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=4:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

# for file in ./dmnd_db/HydDB1/*.fasta; do
#     ./diamond makedb --in ./dmnd_db/HydDB1/${file} --db ./dmnd_db/HydDB1/${file%.*}
#     echo "done ${file}"
# done

# ./diamond makedb --in ./dmnd_db/HydDB1/Fe_hydrogenase.fasta --db ./dmnd_db/HydDB1/Fe_hyd
# ./diamond makedb --in ./dmnd_db/HydDB1/FeFe_hydrogenase_reformated.fasta --db ./dmnd_db/HydDB1/FeFe_hyd
# ./diamond makedb --in ./dmnd_db/HydDB1/NiFe_hydrogenase_reformated.fasta --db ./dmnd_db/HydDB1/NiFe_hyd
# ./diamond makedb --in ./dmnd_db/NCBI_NR/nr.gz --db ./dmnd_db/NCBI_NR/nr
# ./diamond makedb --in ./dmnd_db/UniRef100/uniref100.fasta.gz --db ./dmnd_db/UniRef100/uniref100

# for file in ./dmnd_db/GTDB_r220/protein_faa_reps/archaea/*.gz; do
#     zcat $file | gzip >>./dmnd_db/GTDB_r220/gtdb_archaea.gz
# done
#
# ./diamond makedb --in ./dmnd_db/GTDB_r220/gtdb_archaea.gz --db ./dmnd_db/GTDB_r220/gtdb_archaea
# ./diamond makedb --in ./dmnd_db/GTDB_r220/gtdb_bacteria.gz --db ./dmnd_db/GTDB_r220/gtdb_bacteria
#
# ./diamond makedb --in ./dmnd_db/BFD_Mgnify_db/bfd_mgy_colabfold.gz --db ./dmnd_db/BFD_Mgnify_db/bfd_mgy_colabfold

# tar -xvf ./dmnd_db/BFD_Mgnify_db/bfd_mgy_colabfold.tar.gz
# tar -xvf ./dmnd_db/ColabFold_envdb/colabfold_envdb_202108.tar.gz

# wget https://wwwuser.gwdg.de/~compbiol/colabfold/bfd_mgy_colabfold.tar.gz

# GPU=1 ./setup_databases.sh ./database/ColabFoldDB_GPU/

# ./diamond blastp -q ./dmnd_db/HydDB1/FeFe_hydrogenase_reformated.fasta -d ./dmnd_db/NCBI_NR/nr.dmnd -o FeFe_nr_output.tsv --very-sensitive

./diamond blastp \
    -q ./dmnd_db/HydDB1/Fe_hydrogenase.fasta \
    -d ./dmnd_db/NCBI_NR/nr_taxids.dmnd \
    -o ./output_dmnd/Fe-only-NR-ultrasensitive_v6.tsv \
    --ultra-sensitive \
    --header verbose \
    --outfmt 6 qseqid sseqid staxids salltitles pident length mismatch gapopen qstart qend sstart send evalue bitscore full_sseq

# ./diamond makedb \
#     --in ./dmnd_db/GTDB_r220/gtdb_archaea.gz \
#     --db ./dmnd_db/GTDB_r220/gtdb_archaea_taxids \
#     --taxonmap ./dmnd_db/NCBI_NR/prot.accession2taxid.FULL.gz \
#     --taxonnodes ./dmnd_db/NCBI_NR/nodes.dmp \
#     --taxonnames ./dmnd_db/NCBI_NR/names.dmp
