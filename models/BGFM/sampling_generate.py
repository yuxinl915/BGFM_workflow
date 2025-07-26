import numpy as np
import os

# === User-specified input ===
expression_path = os.getenv("E_addr")
genotype_path = os.getenv("X_addr")
output_dir = os.getenv("to_addr")
n_bootstrap = 100

# === Load input data ===
expression = np.loadtxt(expression_path, delimiter=",")         # shape: (n,)
genotype = np.loadtxt(genotype_path, delimiter=",")             # shape: (n, p)

# Ensure the number of rows match
assert expression.shape[0] == genotype.shape[0], "Mismatched number of samples."


# === Generate bootstrap samples ===
for i in range(n_bootstrap):
    # Sample indices with replacement
    sampled_indices = np.random.choice(expression.shape[0], size=expression.shape[0], replace=True)
    
    # Get resampled data
    expr_sample = expression[sampled_indices]
    geno_sample = genotype[sampled_indices, :]
    
    # Save to files
    np.savetxt(f"{output_dir}/E_bootstrap_{i}.txt", expr_sample)
    np.savetxt(f"{output_dir}/X_bootstrap_{i}.txt", geno_sample)

print(f"Successfully generated {n_bootstrap} bootstrap samples.")
