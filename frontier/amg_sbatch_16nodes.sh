#!/bin/bash
#SBATCH -N 16
#SBATCH -q normal
#SBATCH --gpus-per-node=8
#SBATCH -J amg
#SBATCH --mail-user=keshprad@umd.edu
#SBATCH -t 00:10:00
#SBATCH -A csc569
#SBATCH --output=/lustre/orion/csc569/scratch/keshprad/perfvar/AMG2023_logs/16nodes/%x-%j/output.log
#SBATCH --error=/lustre/orion/csc569/scratch/keshprad/perfvar/AMG2023_logs/16nodes/%x-%j/error.log
#SBATCH --gpu-bind=none
# Run like: sbatch frontier/amg_sbatch_16nodes.sh


# log start date
echo start: $(date)

# reset modules
echo resetting modules:
module reset
# load modules
echo loading modules:
module load cray-mpich/8.1.28
module load craype-accel-amd-gfx90a
module load rocm

OUTPUT_DIR=/lustre/orion/csc569/scratch/keshprad/perfvar/AMG2023_logs/16nodes/$SLURM_JOB_NAME-$SLURM_JOB_ID
export MPICH_GPU_SUPPORT_ENABLED=1
export CRAY_ACCEL_TARGET=gfx90a
export HYPRE_INSTALL_DIR=/ccs/home/keshprad/hypre/src/hypre/
export MPIP="-f $OUTPUT_DIR"

# define command
cmd="srun -n 128 --export=ALL,LD_PRELOAD=/ccs/home/keshprad/mpiP/libmpiP.so ./build/amg -P 4 4 8 -n 128 64 64 -problem 1 -iter 500"
echo solving:
echo $cmd
$cmd

# log end date
echo exit: $(date)
