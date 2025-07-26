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
#SBATCH --mem-per-cpu=50G

## specify the location of our output log
#SBATCH -o /PATH/TO/OUTPUT/LOG


#SBATCH --time=4-03:00:00

chr_num=[PLEASE_ENTER_YOUR_CHROMOSOME_NUM]

root_dir=/PATH/TO/ROOT/DIR/
to_raw_data_plink=$root_dir/raw_data_plink
mkdir $to_raw_data_plink
to_group=$to_raw_data_plink/group
mkdir $to_group

path_to_plink=/PATH/TO/PLINK

$path_to_plink --bfile /projects/zhanglab/data/1000G/GEUVADIS/chr$chr_num --maf 0.05 --geno 0.05 --hwe 1e-50 --make-bed --out $to_raw_data_plink/chr${chr_num}_filtered


head -n 165 $to_raw_data_plink/chr${chr_num}_filtered.fam | awk '{print $1, $2}' > $to_group/group1.txt
tail -n +166 $to_raw_data_plink/chr${chr_num}_filtered.fam | head -n 300 | awk '{print $1, $2}' > $to_group/group2.txt

$path_to_plink --bfile $to_raw_data_plink/chr${chr_num}_filtered --keep $to_group/group1.txt --make-bed --out $to_group/chr${chr_num}_group1

$path_to_plink --bfile $to_raw_data_plink/chr${chr_num}_filtered --keep $to_group/group2.txt --make-bed --out $to_group/chr${chr_num}_group2