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
#SBATCH --array=0-200%50

source activate basicDA
export locus_idx=$SLURM_ARRAY_TASK_ID

root_dir=/PATH/TO/ROOT/DIR/
eqtl_sample_size=[PLEASE_ENTER_SAMPLE_SIZE]

export to_genotype_dir=$root_dir/hapgen_eQTL/hapgen_to_plink/chr1_group1_${locus_idx}_simulated

export to_standardized_genotype_folder=$root_dir/standardized_geno_$eqtl_sample_size
mkdir $to_standardized_genotype_folder

export to_standardized_genotype_dir=$to_standardized_genotype_folder/locus_$locus_idx.csv
python /PATH/TO/bFile_to_csv.py