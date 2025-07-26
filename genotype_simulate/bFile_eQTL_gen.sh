#!/bin/bash
#
#$ -j y
#$ -S /bin/bash
#$ -cwd

## the next line selects the partition/queue
#SBATCH -p mzhang

## the next line selects the number of cores
#SBATCH -n 16

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

export eqtl_sample_size=[PLEASE_ENTER_SAMPLE_SIZE]

chr_num=[PLEASE_ENTER_CHROMOSOME_NUM]

export root_dir=/PATH/TO/ROOT/DIR/

# required packages: plink, shapeit, and hapgen2
export addr_to_plink=/PATH/TO/plink
export addr_to_shapeit=/PATH/TO/shapeit
export addr_to_hapgen2=/PATH/TO/hapgen2

export dir_plink_eQTL=$root_dir/plink_eQTL
mkdir $dir_plink_eQTL
$addr_to_plink --bfile $root_dir/raw_data_plink/group/chr${chr_num}_group1 --chr ${chr_num} --from-bp $start_bp --to-bp $end_bp --make-bed --out $dir_plink_eQTL/chr${chr_num}_group1_$file_idx

export dir_hapgen_eQTL=$root_dir/hapgen_eQTL
mkdir $dir_hapgen_eQTL
export dir_pre_hapgen=$dir_hapgen_eQTL/pre_hapgen
mkdir $dir_pre_hapgen
awk -v start=$start_bp -v end=$end_bp '$1 >= start && $1 < end' /projects/zhanglab/data/1000G/genetic_maps_b37/genetic_map_chr${chr_num}_combined_b37.txt > $dir_pre_hapgen/genetic_map_chr${chr_num}_$file_idx.txt

$addr_to_shapeit -B $dir_plink_eQTL/chr${chr_num}_group1_$file_idx -M $dir_pre_hapgen/genetic_map_chr${chr_num}_$file_idx.txt -O $dir_pre_hapgen/chr${chr_num}_group1_$file_idx --thread 16

export bim_file=$dir_plink_eQTL/chr${chr_num}_group1_$file_idx.bim
export leg_file=/projects/zhanglab/data/1000G/v2/1kG/legend/v2.20101123.chr${chr_num}.legend
export haps_file=$dir_pre_hapgen/chr${chr_num}_group1_$file_idx.haps
export output_leg_file=$dir_pre_hapgen/chr${chr_num}_group1_$file_idx.leg
export output_haps_file=$dir_pre_hapgen/chr${chr_num}_group1_${file_idx}_eventual.haps
export temp_file=$dir_pre_hapgen/temp_pos_$file_idx.txt
python /PATH/TO/generate_leg.py

snp_info=$(cat $temp_file)
pos=$(echo $snp_info | awk '{print $1}')
export SNP_pos=$pos

export dir_post_hapgen=$dir_hapgen_eQTL/post_hapgen
mkdir $dir_post_hapgen
$addr_to_hapgen2 \
  -m $dir_pre_hapgen/genetic_map_chr${chr_num}_$file_idx.txt \
  -l $dir_pre_hapgen/chr${chr_num}_group1_$file_idx.leg \
  -h $dir_pre_hapgen/chr${chr_num}_group1_${file_idx}_eventual.haps \
  -int $start_bp $end_bp \
  -o $dir_post_hapgen/chr${chr_num}_group1_${file_idx}_simulated \
  -n 0 $eqtl_sample_size \
  -dl $SNP_pos 0 2 4

export dir_hapgen_to_plink=$dir_hapgen_eQTL/hapgen_to_plink
mkdir $dir_hapgen_to_plink
$addr_to_plink --gen $dir_post_hapgen/chr${chr_num}_group1_${file_idx}_simulated.cases.gen --sample $dir_post_hapgen/chr${chr_num}_group1_${file_idx}_simulated.cases.sample --oxford-single-chr ${chr_num} --make-bed --out $dir_hapgen_to_plink/chr${chr_num}_group1_${file_idx}_simulated