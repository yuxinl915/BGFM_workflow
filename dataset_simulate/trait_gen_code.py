import numpy as np
import os

to_loci_dir = os.getenv("to_loci_dir")
num_loci = int(os.getenv("num_loci"))

to_standardized_genotype_dir = os.getenv("to_standardized_genotype_dir")
genotype_mat_standard = np.loadtxt(to_standardized_genotype_dir, delimiter=",")

X = genotype_mat_standard.astype(np.float32)
N, M = X.shape

gwas_stats = dict()
sum_mediated_effects = np.zeros(N)
sum_nonmediated_effects = np.zeros(N)
for idx_locus in range(num_loci):
    # read in the mediated effects
    mediated_effects_file = f"{to_loci_dir}locus_{idx_locus}/mediated_effects"
    mediated_effects = np.loadtxt(mediated_effects_file, delimiter=",")
    sum_mediated_effects += mediated_effects
    # read in the non-mediated effects
    nonmediated_effects_file = f"{to_loci_dir}locus_{idx_locus}/nonmediated_effects"
    nonmediated_effects = np.loadtxt(nonmediated_effects_file, delimiter=",")
    sum_nonmediated_effects += nonmediated_effects
# save the mediated and non-mediated effects
def save_np_2_csv(data, filename):
    np.savetxt(filename, data, delimiter=",", fmt="%.6f")
save_np_2_csv(sum_mediated_effects, f"{to_loci_dir}/sum_mediated_effects")
save_np_2_csv(sum_nonmediated_effects, f"{to_loci_dir}/sum_nonmediated_effects")

var_mediated_effects = np.var(sum_mediated_effects)
var_nonmediated_effects = np.var(sum_nonmediated_effects)
genetic_var = np.var(sum_mediated_effects + sum_nonmediated_effects)
gwas_stats["var_mediated_effects"] = var_mediated_effects
gwas_stats["var_nonmediated_effects"] = var_nonmediated_effects
gwas_stats["genetic_var"] = genetic_var

trait_effects = np.random.normal(loc=(sum_mediated_effects + sum_nonmediated_effects), scale=np.sqrt(1-genetic_var))

# standardize the trait effects
trait_effects_standardized = (trait_effects - np.mean(trait_effects)) / np.std(trait_effects)
save_np_2_csv(trait_effects_standardized, f"{to_loci_dir}/trait_effects_standardized")

empirical_vertical_h2 = var_mediated_effects / np.var(trait_effects_standardized)
gwas_stats["empirical_vertical_h2"] = empirical_vertical_h2
empirical_nonmediated_h2 = var_nonmediated_effects / np.var(trait_effects_standardized)
gwas_stats["empirical_nonmediated_h2"] = empirical_nonmediated_h2
# save the gwas_stats
locus_info_file = f"{to_loci_dir}gwas_stats.txt"
with open(locus_info_file, "w") as f:
    for key, value in gwas_stats.items():
        f.write(f"{key}: {value}\n")
print(f"GWAS stats saved to {locus_info_file}")