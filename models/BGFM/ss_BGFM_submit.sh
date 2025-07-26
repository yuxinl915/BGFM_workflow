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

PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
export QTL_sample_size=[PLEASE_ENTER_QTL_SAMPLE_SIZE]
rep=[PLEASE_ENTER_REPLICATION_NUMBER]

export root_dir=/PATH/TO/simulated_percent_${PVE_X_percent}_$rep

export num_genes=[PLEASE_ENTER_NUM_GENES]
export gwas_sample_size=[PLEASE_ENTER_GWAS_SAMPLE_SIZE]

from_dir_sum_stats=$root_dir/sum_stats_$QTL_sample_size
to_subroot=$from_dir_sum_stats/BGFM_results
mkdir $to_subroot

to_locus=$to_subroot/locus_$locus_idx
mkdir $to_locus

from_ld_z_dir=$from_dir_sum_stats/BGFM_z_ld
from_locus=$from_ld_z_dir/locus_$locus_idx

for (( i=0; i<100; i++))
do
  export boot_id=$i
  export to_boot=$to_locus/boot_$boot_id
  mkdir $to_boot
  from_boot=$from_locus/boot_$boot_id
  z_file=$from_boot/z_vector.csv
  R_file=$from_boot/full_ld.csv
  srun --exclusive -n 1 -c 1 --mem-per-cpu 7G Rscript /PATH/TO/ss_BGFM_code.R $to_boot $z_file $R_file $gwas_sample_size
  
done
wait