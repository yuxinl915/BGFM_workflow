import os
import numpy as np

source_dir = os.getenv('source_dir')
to_dir = os.getenv('to_dir')
boot_id = os.getenv('boot_id')

# read in a numpy matrix in a .csv file
alpha = np.loadtxt(f"{source_dir}/alpha.csv", delimiter=",", skiprows=1)
mu = np.loadtxt(f"{source_dir}/mu.csv", delimiter=",", skiprows=1)
mu2 = np.loadtxt(f"{source_dir}/mu2.csv", delimiter=",", skiprows=1)

# calculate the posterior var
var = mu2 - mu**2
print(f"\n\nobtain var shape: {var.shape}")
# print(var)

# for each SUSIE component
np.random.seed(int(boot_id))
result_vec = np.zeros(alpha.shape[1])
for l in range(alpha.shape[0]):
    # determine which entry is the causal one
    causal_idx = np.random.choice(alpha.shape[1], p=alpha[l, :])
    # for each causal entry, the value follows normal
    effect_size = np.random.normal(mu[l, causal_idx], np.sqrt(var[l, causal_idx]))

    component = np.zeros(alpha.shape[1])
    component[causal_idx] = effect_size
    result_vec += component

print(f"\n\nobtain result_vec shape: {result_vec.shape}")
# print(result_vec)

# write the result to a .csv file
np.savetxt(f"{to_dir}/self_gen_{boot_id}.csv", result_vec, delimiter=",")