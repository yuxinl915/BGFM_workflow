#!/bin/bash
#
#$ -j y
#$ -S /bin/bash
#$ -cwd

## the next line selects the partition/queue
#SBATCH -p mzhang

## the next line selects the number of cores

#SBATCH -c 1

## the next line selects the memory size
#SBATCH --mem-per-cpu=6G

## specify the location of our output log
#SBATCH -o /PATH/TO/OUTPUT/LOG

#SBATCH --time=4-03:00:00

## Submit a job array with index values between
#SBATCH --array=0-100%25
source activate r-pure
export locus_idx=$SLURM_ARRAY_TASK_ID
export num_genes=[PLEASE_ENTER_NUM_GENES]

PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
rep=[PLEASE_ENTER_REPLICATION_NUMBER]

export root_dir=/PATH/TO/mul_gene_percent_${PVE_X_percent}_$rep

export X_addr=/PATH/TO/EQTL/GENOTYPE/locus_$locus_idx.csv
pos_dist_dir=$root_dir/pos_dist
mkdir $pos_dist_dir
to_locus_dir=$pos_dist_dir/locus_$locus_idx
mkdir $to_locus_dir
for (( g=1; g<$num_genes; g++ ))
do
  export to_addr=$to_locus_dir/SUSIE_g_$g
  mkdir $to_addr
  export E_addr=$root_dir/locus_$locus_idx/E_gene$g.csv
  srun --exclusive -n 1 -c 1 --mem-per-cpu 5G Rscript /PATH/TO/pos_dist_code.R $E_addr $X_addr $to_addr&
done
wait