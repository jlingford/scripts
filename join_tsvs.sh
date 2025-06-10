#!/usr/bin/bash

#USAGE:
# join_tsvs.sh INPUT
# INPUT should be "fefe", "feon", or "nife"

type=$1

if [[ $type == *nife* ]]; then
    final_file_name='NiFe-GTDB226-all_hits.tsv'
    seed_file='./nife-gtdb226-withmotif-combined3-closest_gtdb226_hits_RAW.tsv'
    cath_filter_list='./nife-cath50_hits_all.txt'
    cath_filter_reps='./nife-cath50_hits_reps.txt'
    INPUT=(
        './nife-gtdb226-withmotif-combined3-closest_HydDB1.dmnd_hits_RAW.tsv'
        './nife-gtdb226-withmotif-combined3-closest_uniref100_hits_RAW.tsv'
        './nife-gtdb226-withmotif-combined3-closest_nr_hits_RAW.tsv'
        './nife-gtdb226-withmotif-combined3_lca.tsv'
    )
elif [[ $type == *fefe* ]]; then
    final_file_name='FeFe-GTDB226-all_hits.tsv'
    seed_file='./fefe-gtdb226-withmotif-combined3-closest_gtdb226_hits_RAW.tsv'
    cath_filter_list='./fefe-cath50_hits_all.txt'
    cath_filter_reps='./fefe-cath50_hits_reps.txt'
    INPUT=(
        './fefe-gtdb226-withmotif-combined3-closest_HydDB1.dmnd_hits_RAW.tsv'
        './fefe-gtdb226-withmotif-combined3-closest_uniref100_hits_RAW.tsv'
        './fefe-gtdb226-withmotif-combined3-closest_nr_hits_RAW.tsv'
        './fefe-gtdb226-withmotif-combined3_lca.tsv'
    )
elif [[ $type == *feon* ]]; then
    final_file_name='Feon-GTDB226-all_hits.tsv'
    seed_file='./feon-gtdb226-combined3-closest_gtdb226_hits_RAW.tsv'
    cath_filter_list='./feon-cath50_hits_all.txt'
    cath_filter_reps='./feon-cath50_hits_reps.txt'
    INPUT=(
        './feon-gtdb226-combined3-closest_HydDB1.dmnd_hits_RAW.tsv'
        './feon-gtdb226-combined3-closest_uniref100_hits_RAW.tsv'
        './feon-gtdb226-combined3-closest_nr_hits_RAW.tsv'
        './feon-gtdb226-combined3_lca.tsv'
    )
else
    echo "input error"
fi

cut -d $'\t' -f1,2,8,9,10,12,16 "$seed_file" >seed2.tsv
awk -F"\t" -vOFS="\t" 'FNR==1{$2="gtdb_id" FS "gtdb_genomeid" FS "gtdb_protaccession"; print; next}{split($2, arr, "~"); $2=$2 FS arr[1] FS arr[2]; print}' seed2.tsv >tmp && mv tmp seed2.tsv
cp seed2.tsv seed.tsv

for i in "${INPUT[@]}"; do
    next_file=$i

    # join tables
    # join --header -a1 -a2 -e "N/A" -t $'\t' -1 1 -2 1 seed.tsv $next_file >tmp && mv tmp seed.tsv
    # NOTE: need to use "-o auto" for "-e "NULL"" to work
    join --header -a1 -a2 -e "NULL" -o auto -t $'\t' -1 1 -2 1 seed.tsv "$next_file" >tmp && mv tmp seed.tsv

done

# remove "full_qseq" columns
cut -d $'\t' -f2-15,17-30,32-45,47- seed.tsv >final_table.tsv

# split "hyddb1_id" column into new column to show hyd group classification
awk -F"\t" -vOFS="\t" 'FNR==1{$9="hyddb1_id" FS "hyddb1_classification"; print; next}{split($9, arr, "|"); $9=$9 FS arr[3]; print}' final_table.tsv >tmp && mv tmp final_table.tsv

# remake header row
sed -i '1d' final_table.tsv
sed -i '1i gtdb_id\tgtdb_genomeid\tgtdb_protaccession\tgtdb_taxids\tgtdb_sscinames\tgtdb_sscikingdoms\tgtdb_sphylums\tgtdb_full_seq\thyddb1_id\thyddb1_classification\thyddb1_pident\thyddb1_evalue\thyddb1_bitscore\thyddb1_qcovhsp\thyddb1_scovhsp\thyddb1_full_seq\tuniref100_id\tuniref100_pident\tuniref100_evalue\tuniref100_bitscore\tuniref100_qcovhsp\tuniref100_scovhsp\tuniref100_taxids\tuniref100_sscinames\tuniref100_sskingdoms\tuniref100_skingdoms\tuniref100_sphylums\tuniref100_stitle\tuniref100_salltitles\tuniref100_full_seq\tncbi_nr_id\tncbi_nr_pident\tncbi_nr_evalue\tncbi_nr_bitscore\tncbi_nr_qcovhsp\tncbi_nr_scovhsp\tncbi_nr_staxids\tncbi_nr_sscinames\tncbi_nr_sskingdoms\tncbi_nr_skingdoms\tncbi_nr_sphylums\tncbi_nr_stitle\tncbi_nr_salltitles\tncbi_nr_full_seq\tlca_taxid\tlca_rank\tlca_species_name' final_table.tsv

# rename table
mv final_table.tsv "$final_file_name"

# make new filtered tables based on CATH50 foldseek hits
grep -f "$cath_filter_list" "$final_file_name" >"${final_file_name/all_hits.tsv/cath50_filtered_hits.tsv}"
grep -f "$cath_filter_reps" "$final_file_name" >"${final_file_name/all_hits.tsv/cath50_filtered_cluster_reps_covm00cov80id50.tsv}"

# add header lines back to these new filtered tables
sed -i '1i gtdb_id\tgtdb_genomeid\tgtdb_protaccession\tgtdb_taxids\tgtdb_sscinames\tgtdb_sscikingdoms\tgtdb_sphylums\tgtdb_full_seq\thyddb1_id\thyddb1_classification\thyddb1_pident\thyddb1_evalue\thyddb1_bitscore\thyddb1_qcovhsp\thyddb1_scovhsp\thyddb1_full_seq\tuniref100_id\tuniref100_pident\tuniref100_evalue\tuniref100_bitscore\tuniref100_qcovhsp\tuniref100_scovhsp\tuniref100_taxids\tuniref100_sscinames\tuniref100_sskingdoms\tuniref100_skingdoms\tuniref100_sphylums\tuniref100_stitle\tuniref100_salltitles\tuniref100_full_seq\tncbi_nr_id\tncbi_nr_pident\tncbi_nr_evalue\tncbi_nr_bitscore\tncbi_nr_qcovhsp\tncbi_nr_scovhsp\tncbi_nr_staxids\tncbi_nr_sscinames\tncbi_nr_sskingdoms\tncbi_nr_skingdoms\tncbi_nr_sphylums\tncbi_nr_stitle\tncbi_nr_salltitles\tncbi_nr_full_seq\tlca_taxid\tlca_rank\tlca_species_name' "${final_file_name/all_hits.tsv/cath50_filtered_hits.tsv}"
sed -i '1i gtdb_id\tgtdb_genomeid\tgtdb_protaccession\tgtdb_taxids\tgtdb_sscinames\tgtdb_sscikingdoms\tgtdb_sphylums\tgtdb_full_seq\thyddb1_id\thyddb1_classification\thyddb1_pident\thyddb1_evalue\thyddb1_bitscore\thyddb1_qcovhsp\thyddb1_scovhsp\thyddb1_full_seq\tuniref100_id\tuniref100_pident\tuniref100_evalue\tuniref100_bitscore\tuniref100_qcovhsp\tuniref100_scovhsp\tuniref100_taxids\tuniref100_sscinames\tuniref100_sskingdoms\tuniref100_skingdoms\tuniref100_sphylums\tuniref100_stitle\tuniref100_salltitles\tuniref100_full_seq\tncbi_nr_id\tncbi_nr_pident\tncbi_nr_evalue\tncbi_nr_bitscore\tncbi_nr_qcovhsp\tncbi_nr_scovhsp\tncbi_nr_staxids\tncbi_nr_sscinames\tncbi_nr_sskingdoms\tncbi_nr_skingdoms\tncbi_nr_sphylums\tncbi_nr_stitle\tncbi_nr_salltitles\tncbi_nr_full_seq\tlca_taxid\tlca_rank\tlca_species_name' "${final_file_name/all_hits.tsv/cath50_filtered_cluster_reps_covm00cov80id50.tsv}"

# clean up
rm seed.tsv seed2.tsv
