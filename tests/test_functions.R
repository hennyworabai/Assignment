# ============================================================================
# Unit Tests for Obesity Dataset Analysis
# Tests for core functions in functions.R
#
# To run tests:
#   source("tests/test_functions.R")
# ============================================================================

# Load required libraries and functions
source("src/functions.R")
source("src/config.R")

# Simple assertion function (substitute for proper testing framework)
assert_equal <- function(actual, expected, message = "") {
  if (!isTRUE(all.equal(actual, expected))) {
    stop(sprintf("Assertion failed: %s\nExpected: %s\nActual: %s",
                 message, expected, actual))
  }
  cat(sprintf("✓ PASS: %s\n", message))
}

assert_true <- function(condition, message = "") {
  if (!condition) {
    stop(sprintf("Assertion failed: %s", message))
  }
  cat(sprintf("✓ PASS: %s\n", message))
}

assert_has_column <- function(df, col_name, message = "") {
  if (!(col_name %in% colnames(df))) {
    stop(sprintf("Assertion failed: %s\nColumn '%s' not found", message, col_name))
  }
  cat(sprintf("✓ PASS: %s\n", message))
}

# ============================================================================
# Test: calculate_bmi
# ============================================================================

cat("\n=== Testing calculate_bmi ===\n")

test_df <- data.frame(
  Weight = c(70, 80, 90),
  Height = c(1.75, 1.80, 1.85)
)

result_df <- calculate_bmi(test_df)

assert_has_column(result_df, "BMI", "BMI column created")
assert_equal(result_df$BMI[1], 70 / (1.75^2), "BMI calculation correct for first row")
assert_equal(result_df$BMI[2], 80 / (1.80^2), "BMI calculation correct for second row")

# ============================================================================
# Test: classify_obesity
# ============================================================================

cat("\n=== Testing classify_obesity ===\n")

test_df <- data.frame(
  BMI = c(17, 22, 27, 32)
)

result_df <- classify_obesity(test_df, BMI_THRESHOLDS)

assert_has_column(result_df, "label", "label column created")
assert_equal(result_df$label[1], "0_underweight", "Underweight classification")
assert_equal(result_df$label[2], "1_normal", "Normal weight classification")
assert_equal(result_df$label[3], "2_overweight", "Overweight classification")
assert_equal(result_df$label[4], "3_obese", "Obese classification")

# ============================================================================
# Test: calculate_class_weights
# ============================================================================

cat("\n=== Testing calculate_class_weights ===\n")

labels <- c("A", "A", "A", "B", "B", "C")
weights <- calculate_class_weights(labels)

assert_true(names(weights)[1] == "A", "Weight for class A exists")
assert_true(names(weights)[2] == "B", "Weight for class B exists")
assert_true(names(weights)[3] == "C", "Weight for class C exists")

# Classes with fewer samples should have higher weight
assert_true(weights["C"] > weights["A"], "Minority class has higher weight")

# ============================================================================
# Test: calculate_metrics
# ============================================================================

cat("\n=== Testing calculate_metrics ===\n")

y_true <- c(1, 2, 3, 4, 5)
y_pred <- c(1.1, 2.1, 2.9, 4.1, 4.9)
y_train <- c(1, 2, 3, 4, 5)

metrics <- calculate_metrics(y_true, y_pred, y_train)

assert_true(is.numeric(metrics$mae_model), "MAE model is numeric")
assert_true(is.numeric(metrics$mae_baseline), "MAE baseline is numeric")
assert_true(metrics$mae_baseline > 0, "MAE baseline is positive")

# Perfect predictions should have MAE near 0
y_pred_perfect <- y_true
metrics_perfect <- calculate_metrics(y_true, y_pred_perfect, y_train)
assert_true(metrics_perfect$mae_model < 0.001, "Perfect predictions have near-zero MAE")

# ============================================================================
# Test: split_datasets
# ============================================================================

cat("\n=== Testing split_datasets ===\n")

test_df <- data.frame(id = 1:10)
split_result <- split_datasets(test_df, c(1, 2, 3))

assert_true(nrow(split_result$web) == 3, "Web dataset has 3 rows")
assert_true(nrow(split_result$synthetic) == 7, "Synthetic dataset has 7 rows")
assert_true(nrow(split_result$web) + nrow(split_result$synthetic) == 10,
            "Total rows preserved")

# ============================================================================
# Test: encode_features (partial test with sample data)
# ============================================================================

cat("\n=== Testing encode_features ===\n")

test_df <- data.frame(
  Gender = c("Male", "Female"),
  MTRANS = c("Walking", "Automobile"),
  FAVC = c("yes", "no"),
  SMOKE = c("no", "yes"),
  SCC = c("yes", "no"),
  CAEC = c("no", "Sometimes"),
  CALC = c("Frequently", "Always")
)

result_df <- encode_features(test_df)

assert_true(is.numeric(result_df$Gender[1]), "Gender encoded to numeric")
assert_true(is.numeric(result_df$MTRANS[1]), "MTRANS encoded to numeric")
assert_equal(result_df$FAVC[1], 1, "FAVC: yes -> 1")
assert_equal(result_df$FAVC[2], 0, "FAVC: no -> 0")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== ALL TESTS PASSED ===\n")
cat("All unit tests completed successfully!\n")
