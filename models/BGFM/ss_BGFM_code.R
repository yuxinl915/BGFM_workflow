# script.R
options(repos = c(CRAN = "https://cloud.r-project.org"))
# Load required library
if (!requireNamespace("susieR", quietly = TRUE)) {
    install.packages("susieR")
}

library(susieR)

args <- commandArgs(trailingOnly = TRUE)
dirName <- args[1]
z_file <- args[2]
R_file <- args[3]
gwas_sample_sizes <- args[4]

print("dirName")
print(dirName)

# Read X and y from CSV files
R_mat <- as.matrix(read.csv(R_file, header=FALSE))
print("read from R_file, which is below")
print(R_file)
z_vec <- as.vector(read.csv(z_file, header=FALSE)[, 1])
print("read from z_file, which is below")
print(z_file)
gwas_sample_sizes <- as.integer(gwas_sample_sizes)

print("the shape of R mat")
print(dim(R_mat))

print("the length of z_vec")
print(length(z_vec))

print("the read-in gwas_sample_sizes")
print(gwas_sample_sizes)

# ensure that R_mat is symmetry
R_sym <- (R_mat+t(R_mat))/2


# Run susie
res <- susie_rss(z=z_vec, R=R_sym, n=gwas_sample_sizes, L=10)

# Assuming res is your susie object
pip <- res$pip
alpha <- res$alpha
mu <- res$mu
mu2 <- res$mu2

# Convert matrices to data frames
alpha_df <- as.data.frame(alpha)
mu_df <- as.data.frame(mu)

write.csv(pip, file = paste0(dirName, "/pip.csv"), row.names = FALSE)
write.csv(alpha_df, file = paste0(dirName, "/alpha.csv"), row.names = FALSE)
write.csv(mu_df, file = paste0(dirName, "/mu.csv"), row.names = FALSE)
write.csv(mu2, file = paste0(dirName, "/mu2.csv"), row.names = FALSE)

sets_ <- res$sets
cs_idx <- sets_$cs_index
write.csv(cs_idx, file = paste0(dirName, "/cs_idx.csv"), row.names = FALSE)
print("R done")