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
export QTL_sample_size=[PLEASE_ENTER_QTL_SAMPLE_SIZE]

export root_dir=/PATH/TO/simulated_percent_${PVE_X_percent}_$rep

export num_genes=[PLEASE_ENTER_NUM_GENES]

from_dir_sum_stats=$root_dir/sum_stats_$QTL_sample_size
from_ss_locus=$from_dir_sum_stats/locus_$locus_idx
export ld_variants_file=$from_ss_locus/LD.csv
export gwas_coeffs_file=$from_ss_locus/bhat.csv
export gwas_coeffs_se_file=$from_ss_locus/shat.csv

from_dir_sampling=$root_dir/TGFM_sampling_$PVE_X_percent

export from_dir_locus=$from_dir_sampling/locus_$locus_idx

to_dir_subroot=$from_dir_sum_stats/TGFM_z_ld
mkdir $to_dir_subroot
to_dir_locus=$to_dir_subroot/locus_$locus_idx
mkdir $to_dir_locus

for (( i=0; i<100; i++))
do
  export boot_id=$i
  export to_dir_boot=$to_dir_locus/boot_$boot_id
  mkdir $to_dir_boot
  srun --exclusive -n 1 -c 1 --mem-per-cpu 7G python /PATH/TO/z_ld_TGFM_code.py
  
done
wait