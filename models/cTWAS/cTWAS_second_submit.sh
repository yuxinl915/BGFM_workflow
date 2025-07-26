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
source activate r-pure
export locus_idx=$SLURM_ARRAY_TASK_ID
export PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
export QTL_sample_size=[PLEASE_ENTER_QTL_SAMPLE_SIZE]
export rep=[PLEASE_ENTER_REPLICATION_NUMBER]

root_dir=/PATH/TO/simulated_percent_${PVE_X_percent}_$rep
from_dir_sum_stats=$root_dir/sum_stats_$QTL_sample_size

from_dir_ss_computed=$from_dir_sum_stats/cTWAS_z_ld
from_dir_ss_locus=$from_dir_ss_computed/locus_$locus_idx

export gwas_sample_size=[PLEASE_ENTER_GWAS_SAMPLE_SIZE]

export z_file=$from_dir_ss_locus/z_vector.csv
export R_file=$from_dir_ss_locus/full_ld.csv

to_dir_subroot=$from_dir_sum_stats/cTWAS_results
mkdir $to_dir_subroot
export to_dir_locus=$to_dir_subroot/locus_$locus_idx
mkdir $to_dir_locus

Rscript /PATH/TO/cTWAS_second_code.R $to_dir_locus $z_file $R_file $gwas_sample_size