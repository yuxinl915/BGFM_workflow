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
#SBATCH --mem-per-cpu=10G

## specify the location of our output log
#SBATCH -o /PATH/TO/OUTPUT/LOG

#SBATCH --time=4-03:00:00

## Submit a job array with index values between
#SBATCH --array=0-100%25

source activate basicDA
export locus_idx=$SLURM_ARRAY_TASK_ID

export root_dir=/PATH/TO/ROOT/DIR/
export to_standardized_genotype_dir=/PATH/TO/STANDARDIZED/GENOTYPE/locus_$locus_idx.csv

export num_direct_SNPs=[PLEASE_ENTER_NUM_DIRECT_SNPS]
export PVE_horizontal=[PLEASE_ENTER_PVE_HORIZONTAL]
export PVE_gene=[PLEASE_ENTER_PVE_GENE]
export num_gene=[PLEASE_ENTER_NUM_GENE]
export num_locus=[PLEASE_ENTER_NUM_LOCI]
export causal_gene=[PLEASE_ENTER_CAUSAL_GENE]

PVE_X_percent=[PLEASE_ENTER_PVE_X_PERCENT]
rep=[PLEASE_ENTER_REPLICATION_NUMBER]

folder_high_her_eQTL=$root_dir/mul_gene_percent_${PVE_X_percent}_$rep
export to_locus_dir=$folder_high_her_eQTL/locus_$locus_idx

python /PATH/TO/GWAS_effect_sizes_code.py