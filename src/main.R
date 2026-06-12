# ============================================================================
# Main Analysis Script - Obesity Dataset Analysis
# Refactored according to Reproducible Coding Practices
#
# This script orchestrates the entire analysis pipeline:
# 1. Download and load data
# 2. Preprocess and feature engineering
# 3. Train machine learning model
# 4. Evaluate performance
# ============================================================================

# Clean environment
rm(list = ls())

# Set seed for reproducibility
set.seed(42)

# Load configuration and functions
source("src/config.R")
source("src/functions.R")

# ============================================================================
# 1. SETUP AND DATA LOADING
# ============================================================================

message("\n=== OBESITY DATASET ANALYSIS ===\n")

# Install and load required packages
required_packages <- c("httr", "readr", "ggplot2", "randomForest")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

# Create output directory
if (!dir.exists(OUTPUT_DIR)) {
  dir.create(OUTPUT_DIR, recursive = TRUE)
}

# Download data (if not already present)
data_csv_path <- file.path(DATA_DIR, DATA_CSV_FILE)
if (!file.exists(data_csv_path)) {
  download_obesity_dataset(DATA_URL, DATA_ZIP_NAME, DATA_DIR)
}

# Load data
df <- load_obesity_data(data_csv_path)

# ============================================================================
# 2. DATA PREPROCESSING
# ============================================================================

message("\n--- Data Preprocessing ---\n")

# Split into web and synthetic data
split_data <- split_datasets(df, WEB_DATA_ROWS)
df_web <- split_data$web
df_synthetic <- split_data$synthetic

# Calculate BMI
df_web <- calculate_bmi(df_web)
df_synthetic <- calculate_bmi(df_synthetic)

# Classify obesity levels based on BMI
df_web <- classify_obesity(df_web, BMI_THRESHOLDS)
df_synthetic <- classify_obesity(df_synthetic, BMI_THRESHOLDS)

message(sprintf("\nObesity distribution (web data):\n"))
print(table(df_web$label))

# Encode categorical features
df_web <- encode_features(df_web)
df_synthetic <- encode_features(df_synthetic)

# ============================================================================
# 3. DATA SPLITTING AND PREPARATION
# ============================================================================

message("\n--- Train-Test Split ---\n")

# Set seed for reproducibility
set.seed(RANDOM_SEED)

# Create train-test split
idx <- seq_len(nrow(df_web))
idx_train <- sample(idx, size = floor(TRAIN_TEST_SPLIT * length(idx)))
idx_test <- setdiff(idx, idx_train)

message(sprintf("Training set: %d samples, Test set: %d samples\n",
                length(idx_train), length(idx_test)))

# Prepare feature matrices and target variables
X_train <- df_web[idx_train, FEATURE_COLUMNS]
X_test <- df_web[idx_test, FEATURE_COLUMNS]
y_train <- df_web$BMI[idx_train]
y_test <- df_web$BMI[idx_test]

# Calculate class weights for weighted evaluation
class_weights <- calculate_class_weights(df_web$label[idx_train])
sample_weights_train <- class_weights[df_web$label[idx_train]]
sample_weights_test <- class_weights[df_web$label[idx_test]]

# ============================================================================
# 4. MODEL TRAINING
# ============================================================================

message("\n--- Model Training ---\n")

# Train Random Forest model
model <- train_model(
  X_train = X_train,
  y_train = y_train,
  ntree = MODEL_NTREE,
  nodesize = MODEL_NODESIZE,
  maxnodes = MODEL_MAXNODES
)

# ============================================================================
# 5. MODEL EVALUATION
# ============================================================================

message("\n--- Model Evaluation ---\n")

# Make predictions
preds_train <- make_predictions(model, X_train)
preds_test <- make_predictions(model, X_test)

# Calculate metrics
train_metrics <- calculate_metrics(y_train, preds_train, y_train, sample_weights_train)
test_metrics <- calculate_metrics(y_test, preds_test, y_train, sample_weights_test)

# Display results
cat("\nTraining Set Results:\n")
cat(sprintf("  MAE (baseline): %.3f\n", train_metrics$mae_baseline))
cat(sprintf("  MAE (model):    %.3f\n", train_metrics$mae_model))

cat("\nTest Set Results:\n")
cat(sprintf("  MAE (baseline): %.3f\n", test_metrics$mae_baseline))
cat(sprintf("  MAE (model):    %.3f\n", test_metrics$mae_model))

# ============================================================================
# 6. VISUALIZATIONS
# ============================================================================

message("\n--- Creating Visualizations ---\n")

# Training set: Predicted vs Actual
png(file.path(OUTPUT_DIR, "predictions_train.png"), width = 800, height = 600)
plot(preds_train, y_train,
     main = "Training Set: Predicted vs Actual BMI",
     xlab = "Predicted BMI",
     ylab = "Actual BMI",
     pch = 16,
     col = rgb(0, 0, 0, 0.5))
abline(a = 0, b = 1, col = "red", lty = 3, lwd = 2)
dev.off()
message("Saved: predictions_train.png")

# Test set: Predicted vs Actual
png(file.path(OUTPUT_DIR, "predictions_test.png"), width = 800, height = 600)
plot(preds_test, y_test,
     main = "Test Set: Predicted vs Actual BMI",
     xlab = "Predicted BMI",
     ylab = "Actual BMI",
     pch = 16,
     col = rgb(0, 0, 0, 0.5))
abline(a = 0, b = 1, col = "red", lty = 3, lwd = 2)
dev.off()
message("Saved: predictions_test.png")

# Feature importance plot
png(file.path(OUTPUT_DIR, "feature_importance.png"), width = 800, height = 600)
varImp <- randomForest::importance(model)
barplot(varImp[order(varImp, decreasing = TRUE)],
        main = "Feature Importance",
        ylab = "Mean Decrease in Impurity",
        las = 2)
dev.off()
message("Saved: feature_importance.png")

# ============================================================================
# 7. SAVE RESULTS
# ============================================================================

message("\n--- Saving Results ---\n")

# Create results data frame
results_summary <- data.frame(
  Dataset = c("Train", "Test"),
  MAE_Baseline = c(train_metrics$mae_baseline, test_metrics$mae_baseline),
  MAE_Model = c(train_metrics$mae_model, test_metrics$mae_model),
  Improvement = c(
    (train_metrics$mae_baseline - train_metrics$mae_model) / train_metrics$mae_baseline * 100,
    (test_metrics$mae_baseline - test_metrics$mae_model) / test_metrics$mae_baseline * 100
  )
)

write.csv(results_summary, file.path(OUTPUT_DIR, "results_summary.csv"), row.names = FALSE)
message("Saved: results_summary.csv")

# Save predictions
predictions_df <- data.frame(
  Actual = c(y_train, y_test),
  Predicted = c(preds_train, preds_test),
  Dataset = c(rep("Train", length(y_train)), rep("Test", length(y_test)))
)
write.csv(predictions_df, file.path(OUTPUT_DIR, "predictions.csv"), row.names = FALSE)
message("Saved: predictions.csv")

# ============================================================================
# 8. SESSION INFO
# ============================================================================

message("\n--- Session Information ---\n")
sessionInfo()

message("\n=== ANALYSIS COMPLETE ===\n")
message(sprintf("Results saved to: %s\n", OUTPUT_DIR))
