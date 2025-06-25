touch slurm_gpu.sh
chmod u+x slurm_gpu.sh

echo "#!/bin/bash -l
#SBATCH -D ./
#SBATCH -J gpu
#SBATCH --mem=60000
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=12
#SBATCH --account=rp24
#SBATCH --gres=gpu:A100:1
#SBATCH --partition=bdi
#SBATCH --qos=bdiq
#SBATCH --time=1:00:00
#SBATCH --mail-user=james.lingford@monash.edu
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_OUT
#SBATCH --error=log-%j.err
#SBATCH --output=log-%j.out

# ---
" >>slurm_gpu.sh
