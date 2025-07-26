import numpy as np
from pyplink import PyPlink
import pickle
import os




# helper functions
def compute_allele_freq(genotype_mat):
    allele_freq = np.mean(genotype_mat, axis=0) / 2
    return allele_freq

def save_np_2_csv(data, file_dir):
    # Save the numpy array to a csv file
    np.savetxt(file_dir, data, delimiter=",")


# obtain the genotype eQTL data in that locus
to_genotype_dir = os.getenv("to_genotype_dir")
with PyPlink(to_genotype_dir) as bed:
    genotype_mat = np.zeros((bed.get_nb_samples(), bed.get_nb_markers()))
    for i, genotype in enumerate(bed):
        genotype_mat[:, i] = genotype[1]


# standardize the genotype matrix
# standardize each SNP assumed HWE
af = compute_allele_freq(genotype_mat)
genotype_mat_standard = np.zeros((genotype_mat.shape))
for i in range(genotype_mat.shape[1]):
    if af[i] == 0 or af[i] == 1:
        continue
    genotype_mat_standard[:, i] = (genotype_mat[:, i] - 2 * af[i]) / np.sqrt(2 * af[i] * (1 - af[i]))

# save the standardized genotype matrix

to_standardized_genotype_dir = os.getenv("to_standardized_genotype_dir")
save_np_2_csv(genotype_mat_standard, to_standardized_genotype_dir)

print(f"Standardized genotype matrix successfully saved to {to_standardized_genotype_dir}")

print("verify the standardized genotype matrix is generated correctly")
genotype_mat_standard_in = np.loadtxt(to_standardized_genotype_dir, delimiter=",")
print(f"Shape of standardized genotype matrix: {genotype_mat_standard_in.shape}")

# verify that each column of the standardized genotype matrix has mean 0 and variance 1
for i in range(genotype_mat_standard_in.shape[1]):
    mean = np.mean(genotype_mat_standard_in[:, i])
    var = np.var(genotype_mat_standard_in[:, i])
    print(f"Column {i}: Mean = {mean}, Variance = {var}")

print("Standardized genotype matrix verification completed.")