#!/bin/bash
#
#$ -j y
#$ -S /bin/bash
#$ -cwd

## the next line selects the partition/queue
#SBATCH -p mzhang-gpu

## the next line selects the number of cores

#SBATCH -c 1

## the next line selects the memory size
#SBATCH --mem-per-cpu=6G

## specify the location of our output log
#SBATCH -o /PATH/TO/OUTPUT/LOG

#SBATCH --time=4-03:00:00

## Submit a job array with index values between
#SBATCH --array=0-100%25
source activate basicDA
export locus_idx=$SLURM_ARRAY_TASK_ID

PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
rep=[PLEASE_ENTER_REPLICATION_NUMBER]
export num_genes=[PLEASE_ENTER_NUM_GENES]

export root_dir=/PATH/TO/mul_gene_percent_${PVE_X_percent}_$rep

to_dir_sampling=$root_dir/BGFM_sampling_$PVE_X_percent
mkdir $to_dir_sampling

to_dir_locus=$to_dir_sampling/locus_$locus_idx
mkdir $to_dir_locus

export X_addr=/PATH/TO/EQTL/GENOTYPE/locus_$locus_idx.csv

for (( g=1; g<$num_genes; g++ ))
do
  export to_addr=$to_dir_locus/bootstrap_g_$g
  mkdir $to_addr
  export E_addr=$root_dir/locus_$locus_idx/E_gene$g.csv
  srun --exclusive -n 1 -c 1 --mem-per-cpu 5G python /PATH/TO/sampling_generate.py
done
wait