# ============================================================================
# Core Functions for Obesity Dataset Analysis
# Modular, well-documented functions for data processing and modeling
# ============================================================================

#' Download Obesity Dataset
#'
#' Downloads the obesity dataset from the UC Irvine ML repository and extracts it.
#'
#' @param url Character. The URL to download the dataset from.
#' @param zip_file Character. Name of the temporary zip file.
#' @param data_dir Character. Directory to extract the data to.
#'
#' @return Invisible. Downloads and extracts files to disk.
#'
#' @details
#' This function downloads a zip file from the specified URL and extracts it
#' to the specified directory. It uses httr::GET to download and stop_for_status
#' to check for HTTP errors.
#'
#' @examples
#' \dontrun{
#'   download_obesity_dataset(url, "data.zip", "data")
#' }
#'
#' @importFrom httr GET write_disk stop_for_status
download_obesity_dataset <- function(url, zip_file, data_dir) {
  if (!dir.exists(data_dir)) {
    dir.create(data_dir, recursive = TRUE)
  }

  message(sprintf("Downloading dataset from: %s", url))
  tmp <- httr::GET(url, httr::write_disk(zip_file, overwrite = TRUE))
  httr::stop_for_status(tmp)

  message("Extracting dataset...")
  unzip(zip_file, exdir = data_dir)
  message(sprintf("Dataset extracted to: %s", data_dir))

  invisible(NULL)
}

#' Load Obesity Dataset
#'
#' Loads the obesity dataset from a CSV file.
#'
#' @param filepath Character. Path to the CSV file.
#'
#' @return Data frame containing the obesity dataset.
#'
#' @details
#' This function reads a CSV file and returns it as a data frame.
#' Column types are automatically detected.
#'
#' @examples
#' \dontrun{
#'   df <- load_obesity_data("data/ObesityDataSet_raw_and_data_sinthetic.csv")
#' }
#'
#' @importFrom readr read_csv
load_obesity_data <- function(filepath) {
  message(sprintf("Loading data from: %s", filepath))
  df <- readr::read_csv(filepath, show_col_types = FALSE)
  message(sprintf("Data loaded: %d rows, %d columns", nrow(df), ncol(df)))
  return(df)
}

#' Split Dataset into Web and Synthetic Data
#'
#' Splits the dataset into web-scraped and synthetic portions.
#'
#' @param df Data frame. The full dataset.
#' @param web_rows Integer vector. Row indices for the web data.
#'
#' @return List containing:
#'   \item{web}{Data frame with web-scraped data}
#'   \item{synthetic}{Data frame with synthetic data}
#'
#' @examples
#' \dontrun{
#'   split_data <- split_datasets(df, 1:498)
#'   df_web <- split_data$web
#'   df_synthetic <- split_data$synthetic
#' }
split_datasets <- function(df, web_rows) {
  message("Splitting data into web and synthetic portions...")
  web_data <- df[web_rows, ]
  synthetic_data <- df[-web_rows, ]
  message(sprintf("Web data: %d rows, Synthetic data: %d rows", nrow(web_data), nrow(synthetic_data)))
  return(list(web = web_data, synthetic = synthetic_data))
}

#' Calculate BMI
#'
#' Calculates Body Mass Index from weight and height.
#'
#' @param df Data frame. Must contain 'Weight' and 'Height' columns.
#'
#' @return Data frame with added 'BMI' column.
#'
#' @details
#' BMI is calculated as: BMI = Weight / Height^2
#'
#' @examples
#' \dontrun{
#'   df <- calculate_bmi(df)
#' }
calculate_bmi <- function(df) {
  if (!("Weight" %in% colnames(df)) || !("Height" %in% colnames(df))) {
    stop("Data frame must contain 'Weight' and 'Height' columns")
  }

  df$BMI <- df$Weight / (df$Height)^2
  return(df)
}

#' Classify Obesity Levels
#'
#' Classifies individuals into obesity categories based on BMI.
#'
#' @param df Data frame. Must contain 'BMI' column.
#' @param thresholds List. Named list with BMI threshold values.
#'
#' @return Data frame with added 'label' column containing obesity classifications.
#'
#' @details
#' Classification categories:
#'   - 0_underweight: BMI < 18.5
#'   - 1_normal: 18.5 <= BMI < 25
#'   - 2_overweight: 25 <= BMI < 30
#'   - 3_obese: BMI >= 30
#'
#' @examples
#' \dontrun{
#'   df <- classify_obesity(df, BMI_THRESHOLDS)
#' }
classify_obesity <- function(df, thresholds) {
  if (!("BMI" %in% colnames(df))) {
    stop("Data frame must contain 'BMI' column")
  }

  outcomes <- character(nrow(df))

  for (i in seq_len(nrow(df))) {
    bmi <- df$BMI[i]
    if (bmi < thresholds$underweight) {
      outcomes[i] <- "0_underweight"
    } else if (bmi < thresholds$normal) {
      outcomes[i] <- "1_normal"
    } else if (bmi < thresholds$overweight) {
      outcomes[i] <- "2_overweight"
    } else {
      outcomes[i] <- "3_obese"
    }
  }

  df$label <- outcomes
  return(df)
}

#' Encode Categorical Features
#'
#' Converts categorical variables to numeric values.
#'
#' @param df Data frame. The dataset to encode.
#'
#' @return Data frame with encoded categorical variables.
#'
#' @details
#' Encoding mapping:
#'   - MTRANS: Walking/Bike -> 1, Public/Auto/Motorbike -> 0
#'   - Gender: Male -> 1, Female -> 0
#'   - Binary columns (family_history, FAVC, SMOKE, SCC): yes -> 1, no -> 0
#'   - Ordinal columns (CAEC, CALC): no=0, Sometimes=1, Frequently=2, Always=3
#'
#' @examples
#' \dontrun{
#'   df <- encode_features(df)
#' }
encode_features <- function(df) {
  message("Encoding categorical features...")

  # Encode transportation method
  df$MTRANS[df$MTRANS == "Walking"] <- 1
  df$MTRANS[df$MTRANS == "Bike"] <- 1
  df$MTRANS[df$MTRANS == "Public_Transportation"] <- 0
  df$MTRANS[df$MTRANS == "Automobile"] <- 0
  df$MTRANS[df$MTRANS == "Motorbike"] <- 0
  df$MTRANS <- as.numeric(df$MTRANS)

  # Encode gender
  df$Gender[df$Gender == "Male"] <- 1
  df$Gender[df$Gender == "Female"] <- 0
  df$Gender <- as.numeric(df$Gender)

  # Encode binary features
  binary_cols <- c("family_history_with_overweight", "FAVC", "SMOKE", "SCC")
  for (col in binary_cols) {
    df[df[[col]] == "yes", col] <- "1"
    df[df[[col]] == "no", col] <- "0"
    df[[col]] <- as.numeric(df[[col]])
  }

  # Encode ordinal features
  df$CAEC <- as.numeric(factor(df$CAEC, levels = c("no", "Sometimes", "Frequently", "Always"))) - 1
  df$CALC <- as.numeric(factor(df$CALC, levels = c("no", "Sometimes", "Frequently", "Always"))) - 1

  message("Feature encoding completed")
  return(df)
}

#' Calculate Class Weights
#'
#' Computes class weights to handle class imbalance.
#'
#' @param labels Factor or character. The class labels.
#'
#' @return Named numeric vector with class weights.
#'
#' @details
#' Class weights are calculated as: n_samples / (n_classes * n_samples_per_class)
#' This helps balance the contribution of underrepresented classes.
#'
#' @examples
#' \dontrun{
#'   weights <- calculate_class_weights(df$label)
#' }
calculate_class_weights <- function(labels) {
  classes <- sort(unique(labels))
  freq <- table(labels)
  weights <- length(labels) / (length(classes) * as.numeric(freq))
  names(weights) <- names(freq)
  return(weights)
}

#' Train Random Forest Model
#'
#' Trains a Random Forest model on the training data.
#'
#' @param X_train Data frame. Training features.
#' @param y_train Numeric. Training target variable.
#' @param ntree Integer. Number of trees in the forest.
#' @param nodesize Integer. Minimum node size.
#' @param maxnodes Integer. Maximum number of nodes.
#'
#' @return Trained randomForest object.
#'
#' @examples
#' \dontrun{
#'   model <- train_model(X_train, y_train, ntree=100, nodesize=5, maxnodes=20)
#' }
#'
#' @importFrom randomForest randomForest
train_model <- function(X_train, y_train, ntree, nodesize, maxnodes) {
  message("Training Random Forest model...")
  model <- randomForest::randomForest(
    x = X_train,
    y = y_train,
    ntree = ntree,
    nodesize = nodesize,
    maxnodes = maxnodes
  )
  message("Model training completed")
  return(model)
}

#' Make Predictions
#'
#' Generates predictions on new data.
#'
#' @param model Trained model object.
#' @param X_new Data frame. New features for prediction.
#'
#' @return Numeric vector of predictions.
#'
#' @examples
#' \dontrun{
#'   preds <- make_predictions(model, X_test)
#' }
#'
#' @importFrom stats predict
make_predictions <- function(model, X_new) {
  predictions <- predict(model, X_new)
  return(predictions)
}

#' Calculate Metrics
#'
#' Calculates evaluation metrics (MAE and baseline MAE).
#'
#' @param y_true Numeric. True values.
#' @param y_pred Numeric. Predicted values.
#' @param y_train Numeric. Training values (for baseline calculation).
#' @param weights Numeric. Sample weights for weighted metrics.
#'
#' @return List containing:
#'   \item{mae_model}{Mean Absolute Error of the model}
#'   \item{mae_baseline}{Mean Absolute Error of the baseline}
#'
#' @examples
#' \dontrun{
#'   metrics <- calculate_metrics(y_test, preds, y_train, weights)
#' }
calculate_metrics <- function(y_true, y_pred, y_train, weights = NULL) {
  if (is.null(weights)) {
    weights <- rep(1, length(y_true))
  }

  # Baseline: mean of training data
  baseline_pred <- rep(mean(y_train), length(y_true))
  mae_baseline <- sum(abs(y_true - baseline_pred) * weights) / sum(weights)

  # Model MAE
  mae_model <- sum(abs(y_true - y_pred) * weights) / sum(weights)

  return(list(
    mae_model = mae_model,
    mae_baseline = mae_baseline
  ))
}
