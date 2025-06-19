#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J mmseqs
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
#SBATCH --output=log-%j.out
#SBATCH --error=log-%j.err

# set env
module purge
module load miniforge3
conda activate /home/jamesl/rp24/scratch_nobackup/jamesl/miniconda/conda/envs/mmseqs2

# build name.dmp, node.dmp from GTDB taxonomy
mkdir taxonomy/ && cd "$_"
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/genomic_files_all/ssu_all.fna.gz
gzip -cd ssu_all.fna.gz >ssu_all.fna
buildNCBITax=$(
    cat <<'EOF'
BEGIN{
  ids["root"]=1;
  rank["c"]="class"l
  rank["d"]="superkingdom";
  rank["f"]="family";
  rank["g"]="genus";
  rank["o"]="order";
  rank["p"]="phylum";
  rank["s"]="species";
  taxCnt=1;
  print "1\t|\t1\t|\tno rank\t|\t-\t|" > "nodes.dmp"
  print "1\t|\troot\t|\t-\t|\tscientific name\t|" > "names.dmp";
}
/^>/{
  str=$2
  for(i=3; i<=NF; i++){ str=str" "$i}
  n=split(str, a, ";");
  prevTaxon=1;
  for(i = 1; i<=n; i++){
    if(a[i] in ids){
      prevTaxon=ids[a[i]];
    }else{
      taxCnt++;
      split(a[i],b,"_");
      printf("%s\t|\t%s\t|\t%s\t|\t-\t|\n", taxCnt, prevTaxon, rank[b[1]]) > "nodes.dmp";
      printf("%s\t|\t%s\t|\t-\t|\tscientific name\t|\n", taxCnt, b[3]) >"names.dmp";
      ids[a[i]]=taxCnt;
      prevTaxon=ids[a[i]];
    }
  }
  gsub(">", "", $1);
  printf("%s\t%s\n", $1, ids[a[n]]) > "mapping";
}
EOF
)
awk -F'\\[loc' '{ print $1}' ssu_all.fna | awk "$buildNCBITax"
touch merged.dmp
touch delnodes.dmp
cd ..

mmseqs createdb ./taxonomy/ssu_all.fna ssu

# add taxonomy to GTDB
mmseqs createtaxdb ssu tmp --ncbi-tax-dump taxonomy/ --tax-mapping-file taxonomy/mapping
mv ssu* taxonomy/
