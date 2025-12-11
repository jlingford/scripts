touch slurm_cpu.sh
chmod u+x slurm_cpu.sh

echo "#!/bin/bash -l
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
#SBATCH --error=logs/%j.err
#SBATCH --output=logs/%j.out

# ---
" >>slurm_cpu.sh
