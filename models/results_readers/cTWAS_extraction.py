import numpy as np
import os


# read in a csv file
num_loci = 101
identifier = os.getenv("cTWAS_identifier")


result_root_dir = "PATH/TO/RESULTS_ROOT_DIR"
num_genes = int(os.getenv("num_genes"))
causal_idx = "PLEASE_ENTER_CAUSAL_GENE_INDEX"

pips_all = list()

print("this is for cTWAS")
for l in range(num_loci):
    addr_first = f"{result_root_dir}/locus_{l}/pip.csv"
    # try:
    pip = np.loadtxt(addr_first, delimiter=",", skiprows=1)

    pips_all.append(pip[:num_genes])

pips_all = np.concatenate(pips_all)
# verify the shape
print(f"pips_all shape: {pips_all.shape}, and the expected shape is ({(num_loci * num_genes)})")
# store the pips_all to a file
np.savetxt(f"{result_root_dir}/pips_cTWAS_{identifier}.csv", pips_all, delimiter=",", fmt="%.6f")