#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J hhsuite
#SBATCH --mem=367000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --account=rp24
#SBATCH --partition=genomicsb
#SBATCH --qos=genomicsbq
#SBATCH --time=48:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# set env
module purge
module load miniforge3
conda activate /fs04/scratch2/rp24/jamesl2/MMseqs2/rp24_scratch2/jamesl2/miniconda/conda/envs/hhblits

# cd ./hhsuite_db
# rsync -tvP --partial https://wwwuser.gwdguser.de/~compbiol/uniclust/2023_02/uniref_mapping.tsv.gz
# wget -vP ./hhsuite_db https://wwwuser.gwdguser.de/~compbiol/uniclust/2023_02/UniRef30_2023_02_hhsuite.tar.gz
# wget -vP ./hhsuite_db https://wwwuser.gwdguser.de/~compbiol/data/hhsuite/databases/hhsuite_dbs/pfamA_35.0.tar.gz
# wget -vP ./hhsuite_db https://wwwuser.gwdguser.de/~compbiol/data/hhsuite/databases/hhsuite_dbs/scop70_1.75_hhsuite3.tar.gz
# wget -vP ./hhsuite_db https://wwwuser.gwdguser.de/~compbiol/data/hhsuite/databases/hhsuite_dbs/pdb100_foldseek_230517.tar.gz
# cd ./hhsuite_db/
# tar xzvf UniRef30_2023_02_hhsuite.tar.gz
# tar xzvf pdb100_foldseek_230517.tar.gz
# tar xzvf pfamA_35.0.tar.gz
# tar xzvf scop70_1.75_hhsuite3.tar.gz

wget -vP ./databases https://bfd.mmseqs.com/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz
cd databases
tar xzvf bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.tar.gz
