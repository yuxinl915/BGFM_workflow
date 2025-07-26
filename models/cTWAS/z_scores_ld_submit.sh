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
export PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
export QTL_sample_size=[PLEASE_ENTER_QTL_SAMPLE_SIZE]

export root_dir=/PATH/TO/simulated_percent_${PVE_X_percent}_4
from_dir_sum_stats=$root_dir/sum_stats_$QTL_sample_size
export raw_eQTL_effects_dir=$root_dir/pos_dist/locus_$locus_idx
export num_genes=[PLEASE_ENTER_NUM_GENES]

from_ss_locus=$from_dir_sum_stats/locus_$locus_idx
export ld_variants_file=$from_ss_locus/LD.csv
export gwas_coeffs_file=$from_ss_locus/bhat.csv
export gwas_coeffs_se_file=$from_ss_locus/shat.csv

dir_to_root=$from_dir_sum_stats/cTWAS_z_ld
mkdir $dir_to_root

export dir_to_locus=$dir_to_root/locus_$locus_idx
mkdir $dir_to_locus

python /PATH/TO/z_scores_ld_comp.py


