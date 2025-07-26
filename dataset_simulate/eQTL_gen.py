#!/usr/bin/env python3
import os
import numpy as np
from pathlib import Path


def load_corr(num_genes: int, corr_path: str | None = None, base_r: float = 0.8) -> np.ndarray:
    """Return a (num_genes x num_genes) positive-definite correlation matrix."""
    if corr_path is not None and Path(corr_path).exists():
        C = np.loadtxt(corr_path, delimiter=",")
        assert C.shape == (num_genes, num_genes), "Correlation matrix wrong size"
        return C
    return C


def gen_effect_sizes_expression(X, M, shared_causal, unique_causal, beta_shared,
                                beta_unique):
    """Generate expression vector and full beta for ONE gene."""
    beta = np.zeros(M, dtype=np.float32)
    beta[shared_causal] = beta_shared
    beta[unique_causal] = beta_unique
    genetic_part = X @ beta
    h2_emp = min(np.var(genetic_part), 0.99)
    expr = np.random.normal(loc=genetic_part,
                            scale=np.sqrt(1 - h2_emp))
    return expr.astype(np.float32), beta, h2_emp


def simulate_locus(num_genes: int = 3):
    # ---------- Load genotype matrix ----------
    geno_path = os.getenv("to_standardized_genotype_dir")
    X = np.loadtxt(geno_path, delimiter=",").astype(np.float32)
    N, M = X.shape

    # ---------- Parameters ----------
    shared_k = int(os.getenv("num_shared_causal_SNPs_eQTL"))
    uniq_k   = int(os.getenv("num_uniq_causal_SNPs_eQTL"))
    PVE      = float(os.getenv("PVE_X_percent")) * 0.01

    per_snp_h2 = PVE / (shared_k + uniq_k)
    save_dir   = Path(os.getenv("to_locus_dir"))
    save_dir.mkdir(parents=True, exist_ok=True)

    # ---------- Choose causal SNPs ----------
    all_snps      = np.arange(M)
    shared_causal = np.random.choice(all_snps, size=shared_k, replace=False)
    remaining     = np.setdiff1d(all_snps, shared_causal)

    uniq_causal_list = []
    for _ in range(num_genes):
        chosen = np.random.choice(remaining, size=uniq_k, replace=False)
        uniq_causal_list.append(chosen)
        remaining = np.setdiff1d(remaining, chosen)

    # ---------- Simulate effect sizes ----------
    # *Shared* effects: multivariate MVN with user-defined corr
    C = load_corr(num_genes, os.getenv("GENE_CORR_PATH"))
    Sigma = C * per_snp_h2
    beta_shared_matrix = np.random.multivariate_normal(
        mean=np.zeros(num_genes),
        cov=Sigma,
        size=shared_k
    ).T   # shape (num_genes, shared_k)

    # *Unique* effects: IID normal
    beta_unique_matrix = np.random.normal(
        0, np.sqrt(per_snp_h2),
        size=(num_genes, uniq_k)
    )

    # ---------- Generate expression & save ----------
    locus_info = {
        "N": N, "M": M,
        "num_genes": num_genes,
        "shared_k": shared_k,
        "uniq_k": uniq_k,
        "PVE": PVE,
        "per_snp_h2": per_snp_h2
    }

    for g in range(num_genes):
        expr, beta, h2_emp = gen_effect_sizes_expression(
            X, M,
            shared_causal,
            uniq_causal_list[g],
            beta_shared_matrix[g],
            beta_unique_matrix[g]
        )

        # save
        np.savetxt(save_dir / f"E_gene{g+1}.csv",   expr, delimiter=",", fmt="%.6f")
        np.savetxt(save_dir / f"beta_gene{g+1}.csv", beta, delimiter=",", fmt="%.6f")
        locus_info[f"empirical_h2_gene{g+1}"] = h2_emp

    # ---------- Write locus summary ----------
    with open(save_dir / "locus_info.txt", "w") as fh:
        for k, v in locus_info.items():
            fh.write(f"{k}: {v}\n")


# -------------------- CLI entry --------------------
if __name__ == "__main__":
    num_genes = int(os.getenv("num_genes"))
    simulate_locus(num_genes=num_genes)
