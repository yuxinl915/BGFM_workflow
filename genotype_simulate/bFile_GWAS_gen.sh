#!/bin/bash
#
#$ -j y
#$ -S /bin/bash
#$ -cwd

## the next line selects the partition/queue
#SBATCH -p mzhang

#SBATCH -c 1

## the next line selects the memory size
#SBATCH --mem-per-cpu=6G

## specify the location of our output log
#SBATCH -o /PATH/TO/OUTPUT/LOG

#SBATCH --time=4-03:00:00

## Submit a job array with index values between
#SBATCH --array=0-200%50

export file_idx=$SLURM_ARRAY_TASK_ID
export start_bp=$((1000000 * file_idx))
export end_bp=$((1000000 * (file_idx + 1)))

export gwas_sample_size=[PLEASE_ENTER_SAMPLE_SIZE]

export root_dir=/PATH/TO/ROOT/DIR/

export addr_to_plink=/PATH/TO/plink
export addr_to_shapeit=/PATH/TO/shapeit
export addr_to_hapgen2=/PATH/TO/hapgen2

chr_num=[PLEASE_ENTER_CHROMOSOME_NUM]

export dir_plink=$root_dir/plink_GWAS
mkdir $dir_plink
$addr_to_plink --bfile $root_dir/raw_data_plink/group/chr1_group2 --chr $chr_num --from-bp $start_bp --to-bp $end_bp --make-bed --out $dir_plink/chr1_group2_$file_idx

export dir_hapgen=$root_dir/hapgen_GWAS
mkdir $dir_hapgen
export dir_pre_hapgen=$dir_hapgen/pre_hapgen
mkdir $dir_pre_hapgen
awk -v start=$start_bp -v end=$end_bp '$1 >= start && $1 < end' /projects/zhanglab/data/1000G/genetic_maps_b37/genetic_map_chr1_combined_b37.txt > $dir_pre_hapgen/genetic_map_chr1_$file_idx.txt

$addr_to_shapeit -B $dir_plink/chr1_group2_$file_idx -M $dir_pre_hapgen/genetic_map_chr1_$file_idx.txt -O $dir_pre_hapgen/chr1_group2_$file_idx --thread 16

export bim_file=$dir_plink/chr1_group2_$file_idx.bim
export leg_file=/projects/zhanglab/data/1000G/v2/1kG/legend/v2.20101123.chr1.legend
export haps_file=$dir_pre_hapgen/chr1_group2_$file_idx.haps
export output_leg_file=$dir_pre_hapgen/chr1_group2_$file_idx.leg
export output_haps_file=$dir_pre_hapgen/chr1_group2_${file_idx}_eventual.haps
export temp_file=$dir_pre_hapgen/temp_pos_$file_idx.txt
python /PATH/TO/generate_leg.py

snp_info=$(cat $temp_file)
pos=$(echo $snp_info | awk '{print $1}')
export SNP_pos=$pos

export dir_post_hapgen=$dir_hapgen/post_hapgen
mkdir $dir_post_hapgen
$addr_to_hapgen2 \
  -m $dir_pre_hapgen/genetic_map_chr1_$file_idx.txt \
  -l $dir_pre_hapgen/chr1_group2_$file_idx.leg \
  -h $dir_pre_hapgen/chr1_group2_${file_idx}_eventual.haps \
  -int $start_bp $end_bp \
  -o $dir_post_hapgen/chr1_group2_${file_idx}_simulated \
  -n 0 $gwas_sample_size \
  -dl $SNP_pos 0 2 4

export dir_hapgen_to_plink=$dir_hapgen/hapgen_to_plink
mkdir $dir_hapgen_to_plink
$addr_to_plink --gen $dir_post_hapgen/chr1_group2_${file_idx}_simulated.cases.gen --sample $dir_post_hapgen/chr1_group2_${file_idx}_simulated.cases.sample --oxford-single-chr 1 --make-bed --out $dir_hapgen_to_plink/chr1_group2_${file_idx}_simulated