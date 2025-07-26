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

source activate basicDA
export locus_idx=$SLURM_ARRAY_TASK_ID
export root_dir=/PATH/TO/ROOT/DIR/
mkdir $root_dir

export to_standardized_genotype_dir=/PATH/TO/STANDARDIZED/GENOTYPE/locus_$locus_idx.csv
export num_shared_causal_SNPs_eQTL=[PLEASE_ENTER_NUM_SHARED_CAUSAL_SNPS]
export num_uniq_causal_SNPs_eQTL=[PLEASE_ENTER_NUM_UNIQ_CAUSAL_SNPS]

# NOTE: this also serves as the job identifier, so the actual PVE_X will be this multiply by 0.01
export PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
rep=[PLEASE_ENTER_REPLICATION_NUMBER]

folder_high_her_eQTL=$root_dir/mul_gene_percent_${PVE_X_percent}_$rep
mkdir $folder_high_her_eQTL
export to_locus_dir=$folder_high_her_eQTL/locus_$locus_idx
mkdir $to_locus_dir

# take the number of genes as 5 as an example, please costomize your own number of genes and correlation matrix
export num_genes=5
export GENE_CORR_PATH=/PATH/TO/my_corr_$num_genes.csv

python /PATH/TO/eQTL_gen.py