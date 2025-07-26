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
#SBATCH --mem-per-cpu=8G

## specify the location of our output log
#SBATCH -o /PATH/TO/OUTPUT/LOG

#SBATCH --time=4-03:00:00

## Submit a job array with index values between
#SBATCH --mail-type=ALL
#SBATCH --mail-user=[PLEASE_ENTER_YOUR_EMAIL]

source activate basicDA

export cTWAS_identifier=[PLEASE_ENTER_JOB_IDENTIFIER]
export eqtl_sample_size=[PLEASE_ENTER_EQTL_SAMPLE_SIZE]
export num_genes=[PLEASE_ENTER_NUM_GENES]
echo "here is the identifier: $cTWAS_identifier"
python /PATH/TO/cTWAS_extraction.py