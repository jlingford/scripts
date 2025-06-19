#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J interproscan
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

# wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.73-104.0/interproscan-5.73-104.0-64-bit.tar.gz
# wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.73-104.0/interproscan-5.73-104.0-64-bit.tar.gz.md5

# Recommended checksum to confirm the download was successful:
# md5sum -c interproscan-5.73-104.0-64-bit.tar.gz.md5
# Must return *interproscan-5.73-104.0-64-bit.tar.gz: OK*
# If not - try downloading the file again as it may be a corrupted copy.

# tar -pxvzf interproscan-5.73-104.0-*-bit.tar.gz

# where:
#     p = preserve the file permissions
#     x = extract files from an archive
#     v = verbosely list the files processed
#     z = filter the archive through gzip
#     f = use archive file

module load python3/3.8.5-gcc8
cd interproscan-5.73-104.0/
python3 setup.py -f interproscan.properties
