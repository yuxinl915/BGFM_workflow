import os
import numpy as np

def standardize_effects(effects_folder, num_genes, ld_variants_file):
    window_LD = np.loadtxt(ld_variants_file, delimiter=",", skiprows=1)
    print(f"LD matrix shape: {window_LD.shape}")
    window_susie_pmces = np.zeros((num_genes, window_LD.shape[0]))
    for idx_gene in range(num_genes):
        gene_tissue_susie_pmces = np.loadtxt(f"{effects_folder}/SUSIE_g_{(idx_gene+1)}/pmces.csv", delimiter=",", skiprows=1)
        gene_var = np.dot(np.dot(gene_tissue_susie_pmces, window_LD), gene_tissue_susie_pmces)
        if gene_var == 0:
            standardize_pmces = gene_tissue_susie_pmces
        else:
            standardize_pmces = gene_tissue_susie_pmces / np.sqrt(gene_var)
        window_susie_pmces[idx_gene, :] = standardize_pmces
    return window_susie_pmces


def extract_full_gene_variants_ld(standardized_eQTL_effects, ld_varaints_file):
    variant_ld = np.loadtxt(ld_varaints_file, delimiter=",", skiprows=1)
    expression_covariance = np.dot(np.dot(standardized_eQTL_effects, variant_ld), np.transpose(standardized_eQTL_effects))
    np.fill_diagonal(expression_covariance, 1.0)
    dd = np.diag(1.0/np.sqrt(np.diag(expression_covariance)))
    ge_ld = np.dot(np.dot(dd, expression_covariance),dd)
    gene_variant_ld = np.dot(standardized_eQTL_effects, variant_ld) # Ngenes X n_variants
    print(f"gene_variant_ld shape: {gene_variant_ld.shape}")
    top = np.hstack((ge_ld, gene_variant_ld))
    bottom = np.hstack((np.transpose(gene_variant_ld), variant_ld))
    full_ld = np.vstack((top,bottom))
    return full_ld

def z_scores_prepare(gwas_coeffs, gwas_coeffs_se, standardized_eQTL_effects):
    variant_z = gwas_coeffs / gwas_coeffs_se
    new_gene_z = np.dot(standardized_eQTL_effects, variant_z)
    z_vector = np.hstack((new_gene_z, variant_z))
    print(f"z_vector shape: {z_vector.shape}")
    return z_vector

if __name__ == "__main__":
    raw_eQTL_effects_dir = os.getenv("raw_eQTL_effects_dir")
    num_genes = int(os.getenv("num_genes"))
    ld_variants_file = os.getenv("ld_variants_file")

    to_dir_locus = os.getenv("dir_to_locus")

    window_susie_pmces = standardize_effects(raw_eQTL_effects_dir, num_genes, ld_variants_file)
    np.savetxt(f"{to_dir_locus}/window_susie_pmces.csv", window_susie_pmces, delimiter=",", fmt="%.6f")

    full_ld = extract_full_gene_variants_ld(window_susie_pmces, ld_variants_file)
    np.savetxt(f"{to_dir_locus}/full_ld.csv", full_ld, delimiter=",", fmt="%.6f")

    # read in gwas coefficients and standard errors
    gwas_coeffs_file = os.getenv("gwas_coeffs_file")
    gwas_coeffs_se_file = os.getenv("gwas_coeffs_se_file")
    gwas_coeffs = np.loadtxt(gwas_coeffs_file, delimiter=",", skiprows=1)
    gwas_coeffs_se = np.loadtxt(gwas_coeffs_se_file, delimiter=",", skiprows=1)

    z_vector = z_scores_prepare(gwas_coeffs, gwas_coeffs_se, window_susie_pmces)
    np.savetxt(f"{to_dir_locus}/z_vector.csv", z_vector, delimiter=",", fmt="%.6f")
    print("Z-scores and LD matrices have been prepared and saved.")




        