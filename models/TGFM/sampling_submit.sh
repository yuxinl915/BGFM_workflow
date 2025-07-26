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
#SBATCH --mem-per-cpu=8G

## specify the location of our output log
#SBATCH -o /PATH/TO/OUTPUT/LOG

#SBATCH --time=4-03:00:00

## Submit a job array with index values between
#SBATCH --array=0-100%50
#SBATCH --mail-type=ALL
#SBATCH --mail-user=[PLEASE_ENTER_YOUR_EMAIL]
source activate basicDA
export locus_idx=$SLURM_ARRAY_TASK_ID

PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
rep=[PLEASE_ENTER_REPLICATION_NUMBER]

export num_genes=[PLEASE_ENTER_NUM_GENES]

export root_dir=/PATH/TO/mul_gene_percent_${PVE_X_percent}_$rep

to_dir_sampling=$root_dir/TGFM_sampling_$PVE_X_percent
mkdir $to_dir_sampling

to_dir_locus=$to_dir_sampling/locus_$locus_idx
mkdir $to_dir_locus

for (( i=0; i<100; i++))
do
  export boot_id=$i
  for (( g=1; g<$num_genes; g++ ))
  do
    export source_dir=$root_dir/pos_dist/locus_$locus_idx/SUSIE_g_$g
    export to_dir=$to_dir_locus/gene_$g
    mkdir $to_dir
    srun --exclusive -n 1 -c 1 --mem-per-cpu 7G python /PATH/TO/mul_gene_sampling.py
  done
done
wait