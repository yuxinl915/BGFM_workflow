# script.R
options(repos = c(CRAN = "https://cloud.r-project.org"))
# Load required library
if (!requireNamespace("susieR", quietly = TRUE)) {
    install.packages("susieR")
}

library(susieR)

args <- commandArgs(trailingOnly = TRUE)
E_addr <- args[1]
X_addr <- args[2]
to_addr <- args[3]

# Read X and y from CSV files
E_raw <- as.vector(read.csv(E_addr, header=FALSE)[, 1])
cat("Before standardization:\n")
cat("Mean =", mean(E_raw), "\n")
cat("SD   =", sd(E_raw), "\n\n")
# Standardize E
E <- (E_raw - mean(E_raw)) / sd(E_raw)
cat("After standardization:\n")
cat("Mean =", mean(E), "\n")
cat("SD   =", sd(E), "\n\n")
X <- as.matrix(read.table(X_addr, sep="", header=FALSE))


print("length E")
print(length(E))
print("shape X")
print(dim(X))




# Assuming res is your susie object
# Run susie
res <- susie(X, E, L = 10)
pip <- res$pip
alpha <- res$alpha
mu <- res$mu
mu2 <- res$mu2

# Convert matrices to data frames
alpha_df <- as.data.frame(alpha)
mu_df <- as.data.frame(mu)

# pmces
alpha_mat <- as.matrix(alpha, nrow=10)
mu_mat <- as.matrix(mu, nrow=10)
pmces <- colSums(alpha_mat * mu_mat)
print("the pmces is as follows")
print(pmces)


write.csv(pip, file = paste0(to_addr, "/pip.csv"), row.names = FALSE)
write.csv(alpha_df, file = paste0(to_addr, "/alpha.csv"), row.names = FALSE)
write.csv(mu_df, file = paste0(to_addr, "/mu.csv"), row.names = FALSE)
write.csv(mu2, file = paste0(to_addr, "/mu2.csv"), row.names = FALSE)
write.csv(pmces, file = paste0(to_addr, "/pmces.csv"), row.names = FALSE)

post_mean <- susie_get_posterior_mean(res)
write.csv(post_mean, file = paste0(to_addr, "/post_mean.csv"), row.names = FALSE)

pip_after_filtering <- susie_get_pip(res, prune_by_cs = TRUE)
write.csv(pip_after_filtering, file = paste0(to_addr, "/pruned_pip.csv"), row.names = FALSE)

sets_ <- res$sets
cs_idx <- sets_$cs_index
write.csv(cs_idx, file = paste0(to_addr, "/cs_idx.csv"), row.names = FALSE)
print("R succeed!")
