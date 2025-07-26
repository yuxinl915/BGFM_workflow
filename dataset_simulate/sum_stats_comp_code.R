options(repos = c(CRAN = "https://cloud.r-project.org"))
# Load required library
if (!requireNamespace("susieR", quietly = TRUE)) {
    install.packages("susieR")
}

library(susieR)
args <- commandArgs(trailingOnly = TRUE)
to_dir <- args[1]
X_dir <- args[2]
y_dir <- args[3]

print("the name of the to dir")
print(to_dir)

X <- as.matrix(read.csv(X_dir, header=FALSE))
print("read from X_dir, which is below")
print(X_dir)
y <- as.vector(read.csv(y_dir, header=FALSE)[, 1])
print("read from y_dir, which is below")
print(y_dir)

sumstats <- univariate_regression(X, y)
R <- cor(X)
R_df <- as.data.frame(R)

bhat <- sumstats$betahat
shat <- sumstats$sebetahat

write.csv(bhat, file = paste0(to_dir, "/bhat.csv"), row.names = FALSE)
write.csv(shat, file = paste0(to_dir, "/shat.csv"), row.names = FALSE)
write.csv(R_df, file = paste0(to_dir, "/LD.csv"), row.names = FALSE)

print("R done!")

