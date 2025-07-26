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
#SBATCH -o /home/yuxinlu/pkgs_tgfm/cohort_generate_thesis/logs/sum_stats_gen_ARRAY%A_%a.out

#SBATCH --time=4-03:00:00

## Submit a job array with index values between
#SBATCH --array=0-100%25
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yuxinlu@cs.cmu.edu
source activate r-pure
export locus_idx=$SLURM_ARRAY_TASK_ID
export PVE_X_percent=8
rep=13
eQTL_sample_sizes=1000

export root_dir=/projects/zhanglab/users/yuxin/realistics_0601/simulated_percent_${PVE_X_percent}_$rep
to_dir_sum_stats=$root_dir/sum_stats_${eQTL_sample_sizes}
mkdir $to_dir_sum_stats
to_dir_locus=$to_dir_sum_stats/locus_$locus_idx
mkdir $to_dir_locus

export X_addr=/projects/zhanglab/users/yuxin/realistics_1012/simulated_GWAS/standardized_geno/locus_$locus_idx.csv
export Y_addr=$root_dir/trait_effects_standardized

Rscript /home/yuxinlu/pkgs_tgfm/cohort_generate_thesis/sum_stats/sum_stats_comp_code.R $to_dir_locus $X_addr $Y_addr