import numpy as np
import os

# read in a csv file
identifier = os.getenv("BGFM_identifier")
num_loci = "PLEASE_ENTER_NUM_LOCI"
num_boots = "PLEASE_ENTER_NUM_BOOTS"
eqtl_sample_size = os.getenv("eqtl_sample_size")
result_root_dir = f"/PATH/TO/ROOT/{identifier}/sum_stats_{eqtl_sample_size}/BGFM_results/"


pips_all = list()
num_genes = int(os.getenv("num_genes"))

for l in range(num_loci):
    num_valid = 0
    addr_first = f"{result_root_dir}/locus_{l}/boot_0/pip.csv"
    try:
        pip_sum = np.loadtxt(addr_first, delimiter=",", skiprows=1)
    except:
        print(f"Error in reading with locus {l} at the beginning")
        continue
    for boot_idx in range(num_boots):
        addr = f"{result_root_dir}/locus_{l}/boot_{boot_idx}/pip.csv"
        try:
            pip = np.loadtxt(addr, delimiter=",", skiprows=1)
            pip_sum += pip
            num_valid += 1
        except:
            print(f"Error in reading with locus {l} and boot {boot_idx}")
    pip_avg = pip_sum / num_valid
    pips_all.append(pip_avg[:num_genes])

# save the pips_all to a file
pips_all = np.concatenate(pips_all)
# verify the shape
print(f"pips_all shape: {pips_all.shape}, and the expected shape is ({(num_loci * num_genes)})")
# store the pips_all to a file
np.savetxt(f"{result_root_dir}/pips_BGFM_{identifier}.csv", pips_all, delimiter=",", fmt="%.6f")