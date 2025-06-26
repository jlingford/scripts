#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J james
#SBATCH --mem=367000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=48
#SBATCH --account=rp24
#SBATCH --partition=genomicsb
#SBATCH --qos=genomicsbq
#SBATCH --time=24:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

# ---

# cd ./fefe-globdb226_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2/fefe-globdb226_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-split_fastas/ || exit
# curate_clusters.sh \
#     /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/globdb_hmmer_mmseqs_covm12cov80id70_cathscreen/fefe-globdb226_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-clust_representatives-43125_seqs-CATH50_subset_list.txt \
#     /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/fefe-combined
# cd ../.. || exit
#
# cd ./feon-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2/feon-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-split_fastas/ || exit
# curate_clusters.sh \
#     /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/globdb_hmmer_mmseqs_covm12cov80id70_cathscreen/feon-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-clust_representatives-4973_seqs-CATH50_subset_list.txt \
#     /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/feon-combined
# cd ../.. || exit
#
# cd ./nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2/nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-split_fastas/ || exit
# curate_clusters.sh \
#     /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/globdb_hmmer_mmseqs_covm12cov80id70_cathscreen/nife_plusmotif-globdb226_hmmer_mmseqs-cov80-id70-covm1-clustm2-clust_representatives-37373_seqs-CATH50_subset_list.txt \
#     /home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/nife-combined
# cd ../.. || exit
#

base='/home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters'
subsetbase='/home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/subsets'
targetbase='/home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/globdb_clusterfilter'
outdir='/home/jamesl/rp24_scratch2/jamesl2/MMseqs2/curate_clusters/output'

targetdirs=(
    "${targetbase}/fefe-combined_hmmer_mmseqs_hits-cov80-id30-covm1-clustm2-split_fastas/"
    "${targetbase}/fefe-combined_hmmer_mmseqs_hits-cov80-id50-covm1-clustm2-split_fastas/"
    "${targetbase}/fefe-combined_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-split_fastas/"
    "${targetbase}/feon-combined_hmmer_mmseqs_hits-cov80-id30-covm1-clustm2-split_fastas/"
    "${targetbase}/feon-combined_hmmer_mmseqs_hits-cov80-id50-covm1-clustm2-split_fastas/"
    "${targetbase}/feon-combined_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-split_fastas/"
    "${targetbase}/nife-withmotif-combined_hmmer_mmseqs_hits-cov80-id30-covm1-clustm2-split_fastas/"
    "${targetbase}/nife-withmotif-combined_hmmer_mmseqs_hits-cov80-id50-covm1-clustm2-split_fastas/"
    "${targetbase}/nife-withmotif-combined_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-split_fastas/"
)
subset_lists=(
    "${subsetbase}/fefe-combined_hmmer_mmseqs_hits-cov80-id30-covm1-clustm2-clust_representatives-6227_seqs-CATH50_subset_list.txt"
    "${subsetbase}/fefe-combined_hmmer_mmseqs_hits-cov80-id50-covm1-clustm2-clust_representatives-11096_seqs-CATH50_subset_list.txt"
    "${subsetbase}/fefe-combined_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-clust_representatives-30475_seqs-CATH50_subset_list.txt"
    "${subsetbase}/feon-combined_hmmer_mmseqs_hits-cov80-id30-covm1-clustm2-clust_representatives-6780_seqs-CATH50_subset_list.txt"
    "${subsetbase}/feon-combined_hmmer_mmseqs_hits-cov80-id50-covm1-clustm2-clust_representatives-14245_seqs-CATH50_subset_list.txt"
    "${subsetbase}/feon-combined_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-clust_representatives-33621_seqs-CATH50_subset_list.txt"
    "${subsetbase}/nife-withmotif-combined_hmmer_mmseqs_hits-cov80-id30-covm1-clustm2-clust_representatives-5348_seqs-CATH50_subset_list.txt"
    "${subsetbase}/nife-withmotif-combined_hmmer_mmseqs_hits-cov80-id50-covm1-clustm2-clust_representatives-45827_seqs-CATH50_subset_list.txt"
    "${subsetbase}/nife-withmotif-combined_hmmer_mmseqs_hits-cov80-id70-covm1-clustm2-clust_representatives-221634_seqs-CATH50_subset_list.txt"
)

for i in "${!targetdirs[@]}"; do
    cd "${targetdirs[i]}" || exit
    echo -e "working on... ${targetdirs[i]}"
    echo -e "pwd: $(pwd)"
    echo -e "subset list... ${subset_lists[i]}"
    echo -e "..."
    curate_clusters.sh "${subset_lists[i]}" ${outdir}
    cd ${base}
    echo -e "done!"
    echo -e "pwd: $(pwd)"
    echo -e ""
done

echo "DONE"
