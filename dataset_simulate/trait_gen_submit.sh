#!/bin/bash
#
#$ -j y
#$ -S /bin/bash
#$ -cwd

## the next line selects the partition/queue
#SBATCH -p mzhang

## the next line selects the number of cores
#SBATCH -n 1

#SBATCH -c 1

## the next line selects the memory size
#SBATCH --mem-per-cpu=10G

## specify the location of our output log
#SBATCH -o /PATH/TO/OUTPUT/LOG


#SBATCH --time=4-03:00:00


source activate basicDA
export to_loci_dir=/PATH/SAME/AS/THE/ONE/IN/GWAS_effect_sizes_code.py
export num_loci=101
export to_standardized_genotype_dir=/PATH/TO/STANDARDIZED/GENOTYPE/locus_0.csv

python /PATH/TO/trait_gen_code.py