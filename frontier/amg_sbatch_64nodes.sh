#!/bin/bash
#SBATCH -N 64
#SBATCH -n 512
#SBATCH -q normal
#SBATCH -J amg
#SBATCH -t 00:30:00
#SBATCH -A csc569
#SBATCH --output /lustre/orion/csc569/scratch/keshprad/perfvar/AMG2023_logs/64nodes/%x-%j/output-AMG2023.log
#SBATCH --error /lustre/orion/csc569/scratch/keshprad/perfvar/AMG2023_logs/64nodes/%x-%j/error-AMG2023.log
# Run like: sbatch frontier/amg_sbatch_64nodes.sh

OUTPUT_DIR=/lustre/orion/csc569/scratch/keshprad/perfvar/AMG2023_logs/64nodes/$SLURM_JOB_NAME-$SLURM_JOB_ID
OUTPUT_FILE=$OUTPUT_DIR/output-AMG2023.log
ERROR_FILE=$OUTPUT_DIR/error-AMG2023.log

# Run gpu benchmarks
COMM_TYPE=mpi
echo running allreduce benchmark
bash /ccs/home/keshprad/gpu-benchmarks/benchmark/frontier/allreduce.sh $COMM_TYPE $SLURM_JOB_NUM_NODES $OUTPUT_DIR
# echo running allgather benchmark
# bash /ccs/home/keshprad/gpu-benchmarks/benchmark/frontier/allgather.sh $COMM_TYPE $SLURM_JOB_NUM_NODES $OUTPUT_DIR
echo running gemm benchmark
bash /ccs/home/keshprad/gpu-benchmarks/benchmark/frontier/gemm.sh $SLURM_JOB_NUM_NODES $OUTPUT_DIR

APP_ROOT=/ccs/home/keshprad/AMG2023
cd $APP_ROOT

# reset modules
echo resetting modules:
module reset
# load modules
echo loading modules:
module load cray-mpich/8.1.28
module load craype-accel-amd-gfx90a
module load rocm

export MPICH_GPU_SUPPORT_ENABLED=1
export CRAY_ACCEL_TARGET=gfx90a
export HYPRE_INSTALL_DIR=/ccs/home/keshprad/hypre/src/hypre/
export MPIP="-f $OUTPUT_DIR"

# log start date
echo start AMG2023: $(date)
# define command
cmd="srun --export=ALL,LD_PRELOAD=/ccs/home/keshprad/mpiP/libmpiP.so \
        --output $OUTPUT_FILE \
        --error $ERROR_FILE \
        ./build/amg -P 8 8 8 -n 128 64 64 -problem 1 -iter 500"
echo solving:
echo $cmd
$cmd
# log end date
echo end AMG2023: $(date)
