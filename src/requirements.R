# ============================================================================
# Package Requirements
# Specifies all R package dependencies for this project
# ============================================================================
# To install all dependencies, run:
#   source("src/requirements.R")

# Core data processing packages
packages <- c(
  "httr",           # HTTP client for downloading data
  "readr",          # Fast CSV reading
  "ggplot2",        # Data visualization
  "randomForest"    # Random Forest implementation
)

# Installation function
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    message(sprintf("Installing %s...", pkg))
    install.packages(pkg, repos = "http://cran.us.r-project.org")
    library(pkg, character.only = TRUE)
  } else {
    message(sprintf("%s is already installed", pkg))
  }
}

# Install all packages
message("Installing required packages...")
invisible(lapply(packages, install_if_missing))
message("All packages installed successfully!")
