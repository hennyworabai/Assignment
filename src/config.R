# ============================================================================
# Configuration File
# Contains all constants, URLs, and settings for the analysis
# ============================================================================

# Data source configuration
DATA_URL <- "https://archive.ics.uci.edu/static/public/544/estimation+of+obesity+levels+based+on+eating+habits+and+physical+condition.zip"
DATA_ZIP_NAME <- "data.zip"
DATA_DIR <- "data"
DATA_CSV_FILE <- "ObesityDataSet_raw_and_data_sinthetic.csv"

# Data split configuration
WEB_DATA_ROWS <- 1:498
RANDOM_SEED <- 42
TRAIN_TEST_SPLIT <- 0.7

# Feature columns
FEATURE_COLUMNS <- c(
  'Age', 'Gender', 'family_history_with_overweight',
  'FAVC', 'FCVC', 'NCP', 'CAEC', 'SMOKE', 'CH2O', 'SCC', 'FAF', 'TUE',
  'CALC', 'MTRANS'
)

# BMI classification thresholds
BMI_THRESHOLDS <- list(
  underweight = 18.5,
  normal = 25,
  overweight = 30
)

# Model configuration
MODEL_NTREE <- 100
MODEL_NODESIZE <- 5
MODEL_MAXNODES <- 20

# Output configuration
OUTPUT_DIR <- "output"
