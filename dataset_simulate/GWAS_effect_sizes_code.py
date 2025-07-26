import numpy as np
import os


to_standardized_genotype_dir = os.getenv("to_standardized_genotype_dir")
genotype_mat_standard = np.loadtxt(to_standardized_genotype_dir, delimiter=",")

gwas_info = dict()
X = genotype_mat_standard.astype(np.float32)
N, M = X.shape

num_direct_SNPs = int(os.getenv("num_direct_SNPs"))
PVE_horizontal = float(os.getenv("PVE_horizontal"))
PVE_gene = float(os.getenv("PVE_gene"))
num_locus = int(os.getenv("num_locus"))
to_locus_dir = os.getenv("to_locus_dir")

# note that this index may be 1-based by default
causal_gene_idx = int(os.getenv("causal_gene"))

gwas_info["num_locus"] = num_locus
# generate horizontal pleiotropy effect sizes
direct_h2_per_snp = PVE_horizontal / (num_direct_SNPs* num_locus)
gwas_info["direct_h2_per_snp"] = direct_h2_per_snp

# Step 1: Choose direct causal SNPs
all_snps = np.arange(M)
direct_causal = np.random.choice(all_snps, size=num_direct_SNPs, replace=False)
# Step 2: Simulate direct effect sizes
direct_sizes = np.random.normal(0, np.sqrt(direct_h2_per_snp), size=num_direct_SNPs)

# Step 3: Generate horizontal pleiotropy effect sizes
gamma_direct = np.zeros(M)
gamma_direct[direct_causal] = direct_sizes

# store gamma_direct
def save_np_2_csv(data, filename):
    np.savetxt(f"{to_locus_dir}/{filename}", data, delimiter=",", fmt="%.6f")

save_np_2_csv(gamma_direct, "gamma_direct")

print("direct effect sizes generation done")

# assume one causal gene per locus
med_express_h2_per_gene = PVE_gene / num_locus
gwas_info["med_express_h2_per_gene"] = med_express_h2_per_gene

# Step 4: Generate mediation effect sizes

gene_to_trait_effects = np.random.normal(0, np.sqrt(med_express_h2_per_gene), size=1)
save_np_2_csv(gene_to_trait_effects, "gene_to_trait_effects")

# save the gwas_info
locus_info_file = f"{to_locus_dir}/gwas_effect_sizes.txt"
with open(locus_info_file, "w") as f:
    for key, value in gwas_info.items():
        f.write(f"{key}: {value}\n")
print(f"GWAS effect sizes info saved to {locus_info_file}")

# compute the mediated express
mediated_effects = np.zeros(N)
nonmediated_effects = np.zeros(N)

snps_to_gene_effects_file = f"{to_locus_dir}/beta_gene{causal_gene_idx}.csv"
snps_to_gene_effects = np.loadtxt(snps_to_gene_effects_file, delimiter=",")

mediated_express = X @ snps_to_gene_effects
mediated_express_std = np.std(mediated_express)
standard_mediated_express = mediated_express / mediated_express_std
mediated_effects = standard_mediated_express * gene_to_trait_effects

# save the mediated_effects
mediated_effects_file = f"{to_locus_dir}/mediated_effects"
save_np_2_csv(mediated_effects, "mediated_effects")

# compute the non-mediated effects
nonmediated_effects = X @ gamma_direct
# save the non-mediated effects
nonmediated_effects_file = f"{to_locus_dir}/nonmediated_effects"
save_np_2_csv(nonmediated_effects, "nonmediated_effects")