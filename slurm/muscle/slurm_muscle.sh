#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J muscle
#SBATCH --mem=867000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --account=rp24
#SBATCH --partition=genomicsb
#SBATCH --qos=genomicsbq
#SBATCH --time=14:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

module purge
module load miniforge3
conda activate /fs04/scratch2/rp24/jamesl2/MMseqs2/mafft_dir/rp24_scratch2/jamesl2/miniconda/conda/envs/muscle

INPUT=FeFe-gtdb-hmmsearch-subseqs.faa

# DATE=$(date +%y%m%d)

# align (<1000 seqs)
# muscle -align ${INPUT} -output ./output/${INPUT%.*}_muscle_aln.afa

# super5 (>1000 seqs)
muscle -super5 ${INPUT} -output ./output/${INPUT%.*}_super5_aln.afa

# # Check MSA dispersion for PPP algorithm
# muscle -align ${INPUT} -stratified -output ${INPUT%.*}_ensemble.efa
# muscle -disperse *_ensemble.efa -log ${INPUT%.*}_dispersion.log

# Check MSA dispersion for Super5 algorithm
# muscle -super5 ${INPUT} -output ./replicates/${INPUT%.*}_replicates.@.afa --perturb 3 -perm all
# create filename.txt needed for -fa2efa
# la replicates | awk '{print $NF}' | grep -E "${INPUT%.*}" | awk '{printf "./replicates/%s\n", $1}' >>./replicates/${INPUT%.*}_filenames.txt
# muscle -fa2efa ./replicates/${INPUT%.*}_filenames.txt -output ./replicates/${INPUT%.*}_ensemble.efa
# muscle -disperse ./replicates/${INPUT%.*}_ensemble.efa -log ./replicates/${INPUT%.*}_dispersion.log
