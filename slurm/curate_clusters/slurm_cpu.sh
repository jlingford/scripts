#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J james
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

# ---

cd ./fefe-globdb226_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2/fefe-globdb226_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-split_fastas/ || exit
curate_clusters.sh \
    /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/globdb_hmmer_mmseqs_covm12cov80id70_cathscreen/fefe-globdb226_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-clust_representatives-43125_seqs-CATH50_subset_list.txt \
    /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/fefe-combined
cd ../.. || exit

cd ./feon-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2/feon-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-split_fastas/ || exit
curate_clusters.sh \
    /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/globdb_hmmer_mmseqs_covm12cov80id70_cathscreen/feon-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-clust_representatives-4973_seqs-CATH50_subset_list.txt \
    /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/feon-combined
cd ../.. || exit

cd ./nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2/nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-split_fastas/ || exit
curate_clusters.sh \
    /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/globdb_hmmer_mmseqs_covm12cov80id70_cathscreen/nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-clust_representatives-37373_seqs-CATH50_subset_list.txt \
    /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/nife-combined
cd ../.. || exit
