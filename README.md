# BGFM_workflow
The workflow of BGFM and competing methods cTWAS and TGFM, also the code for data generation procedure of simulations.

## To obtain your genotype

Please consider below files to simulate the genotype.  
1) run groups_div.sh: the original 1000G project has 465 samples; we use the first 165 samples to simulate the eQTL genotypes and the later 300 samples to simulate the GWAS genotypes;  
2) run bFile_eQTL_gen.sh: apply hapgen2 to simulate the eQTL genotype based on the first 165 samples;  
3) run bFile_GWAS_gen.sh: apply hapgen2 to simulate the GWAS genotypes based on the later 300 samples;  
4) run bFile2CSV_submit.sh: convert the genotypes in plink format to .csv (OPTIONAL)  

## To obtain your dataset

Please consider below files to simulate the eQTL and GWAS datasets.  
1) run eQTL_gen_submit.sh: simulate the SNPs-to-gene effect sizes and the expressions. The matrix my_corr_5.csv is given as an example of the correlation matrix for the shared eQTLs for the genetic components within the same locus;  
2) run GWAS_effect_sizes_submit.sh: simulate the mediated and non-mediated effects from each locus;  
3) run trait_gen_submit.sh: based on the genetic effects from each locus, simulate the phenotype;  
4) run sum_stats_comp_submit.sh: obtain the summary statistics for the SNPs from each locus; the models usually leverage GWAS cohorts with more than 10, 000 samples, and hence only the summary statistics rather than the individual level data is available at the most of the time.  

## To apply the methods

run pos_dist_submit.sh: obtain the posterior distribution for cTWAS fine-mapping and sampling procedures for TGFM.  

### cTWAS
1) z_scores_ld_submit.sh: compute the z_scores and ld matrix for the later fine-mapping;  
2) cTWAS_second_submit.sh: perform the second stage fine-mapping;  

### TGFM
1) sampling_submit.sh: sample the SNPs-to-gene effect sizes based on the posterior distribution of the original eQTL cohorts;  
2) z_ld_TGFM_submit.sh: compute the z_scores and ld matrix for the later fine-mapping;  
3) ss_TGFM_second_submit.sh: perform the second stage fine-mapping;

### BGFM
1) sampling_submit.sh: generate the bootstrapping samples based on the original eQTL cohorts;  
2) pos_dists_submit.sh: obtain the posterior distributions for all the bootstrapping samples;  
3) z_ld_submit.sh: compute the z_scores and ld matrix for the later fine-mapping;  
4) ss_BGFM_submit.sh: perform the second stage fine-mapping;  

## conda environments
1) basicDA: packages for python; not all the packages are necessary, maybe pyplink and numpy are all you needed for above;  
2) r-pure: the environment for running R code; (tips: no one has run rpy2 in our cluster so far, so my current approaches might be the best if you want to run R scripts)  
