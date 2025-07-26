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
source activate r-pure
export locus_idx=$SLURM_ARRAY_TASK_ID
export num_genes=[PLEASE_ENTER_NUM_GENES]

PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
rep=[PLEASE_ENTER_REPLICATION_NUMBER]

export root_dir=/PATH/TO/mul_gene_percent_${PVE_X_percent}_$rep

to_dir_PD=$root_dir/BGFM_post_dists_$PVE_X_percent
mkdir $to_dir_PD

to_dir_locus=$to_dir_PD/locus_$locus_idx
mkdir $to_dir_locus


for (( g=1; g<$num_genes; g++ ))
do
  export to_addr_gene=$to_dir_locus/bootstrap_susie_g_$g
  mkdir $to_addr_gene
  export from_sample_gene=$root_dir/BGFM_sampling_$PVE_X_percent/locus_$locus_idx/bootstrap_g_$g
  for (( i=0; i<100; i++))
  do
    export X_addr=$from_sample_gene/X_bootstrap_$i.txt
    export E_addr=$from_sample_gene/E_bootstrap_$i.txt
    export to_addr=$to_addr_gene/pos_dist_b_$i
    mkdir $to_addr
    srun --exclusive -n 1 -c 1 --mem-per-cpu 7G Rscript /PATH/TO/pos_dists_cal.R $E_addr $X_addr $to_addr
  done
done
wait