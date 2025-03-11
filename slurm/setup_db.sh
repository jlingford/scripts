#!/bin/bash
#SBATCH --job-name="setup_db"
#SBATCH --account=rp24
#SBATCH --partition=genomicsb
#SBATCH --qos=genomicsbq
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=80000
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --chdir="/home/jamesl/rp24_scratch2/jamesl2/MMseqs2"
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# cd database/BFD_Mgnify_env
# wget https://wwwuser.gwdg.de/~compbiol/colabfold/bfd_mgy_colabfold.tar.gz

# wget -v -P ./dmnd_db/UniRef100/ https://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref100/uniref100.fasta.gz

# rsync -t -v -P --partial rsync://data.gtdb.ecogenomic.org/releases/release220/220.0/genomic_files_reps/gtdb_proteins_aa_reps_r220.tar.gz ./dmnd_db/GTDB_r220/

# rsync -tvP --partial rsync://ftp.ncbi.nih.gov/pub/taxonomy/taxdmp.zip ./dmnd_db/NCBI_NR/
# rsync -tvP --partial rsync://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.FULL.gz ./dmnd_db/NCBI_NR/

./diamond

#module purge
#module load miniforge3
#conda activate /home/jamesl/rp24/scratch_nobackup/jamesl/miniconda/conda/envs/mmseqs2

#mmseqs database setup
#mmseqs databases \
# NR \
#     ./database/NCBI_NR_db/ncbi_nr \
#     ./tmp \
#     --remove-tmp-files 1 \
#     --threads 24
