# Assignment - Reproducible Coding Practices
## Refactoring Obesity Dataset Code

This project refactors the obesity dataset analysis code following best practices for reproducible coding.

### Quick Start

```powershell
# Run the complete analysis
& "C:\Program Files\R\R-4.6.0\bin\R.exe" < src/main.R

# Run unit tests
& "C:\Program Files\R\R-4.6.0\bin\R.exe" < tests/test_functions.R
```

---

## Project Structure

```
├── data/                    # Raw data files (downloads here automatically)
├── src/                     # Source code
│   ├── main.R              # Main analysis orchestration script
│   ├── config.R            # Configuration and constants
│   ├── functions.R         # Core modular functions
│   ├── requirements.R      # Package dependencies
│   └── utils.R             # Utility functions (future)
├── tests/                  # Unit tests
│   └── test_functions.R    # Tests for core functions
├── output/                 # Results, plots, and metrics
├── part1a_r.Rmd           # Original assignment specification
└── README.md              # This file
```

---

## Refactoring Summary

### Key Improvements

#### 1. **Modularity**
- Original: Monolithic script with repeated code and implicit dependencies
- Refactored: Functions extracted into modular, reusable components
- Each function has a single responsibility

**Functions created:**
- `download_obesity_dataset()` - Data download and extraction
- `load_obesity_data()` - CSV loading with error handling
- `split_datasets()` - Separate web vs synthetic data
- `calculate_bmi()` - BMI calculation
- `classify_obesity()` - BMI to obesity categories
- `encode_features()` - Categorical encoding
- `calculate_class_weights()` - Class imbalance handling
- `train_model()` - Model training
- `make_predictions()` - Prediction generation
- `calculate_metrics()` - Evaluation metrics

#### 2. **Documentation**
- Original: Minimal inline comments
- Refactored: Roxygen2-style docstrings with:
  - Function descriptions
  - Parameter documentation
  - Return value specifications
  - Details and examples
  - Import statements

#### 3. **Configuration Management**
- Original: Constants hardcoded throughout
- Refactored: Centralized in `config.R`:
  - URLs, file paths, data parameters
  - Model hyperparameters
  - Feature column names
  - BMI thresholds

#### 4. **Error Handling**
- Original: No explicit error checking
- Refactored: Functions validate inputs (e.g., required columns)

#### 5. **Testing**
- Original: Manual verification only
- Refactored: Unit tests in `tests/test_functions.R` covering:
  - BMI calculations
  - Obesity classification
  - Feature encoding
  - Class weight calculation
  - Metrics calculation

#### 6. **Dependency Management**
- Original: Package installation embedded in script
- Refactored: Dedicated `requirements.R` for clear dependency declaration

#### 7. **Output Organization**
- Original: No structured output
- Refactored: Results saved to `output/`:
  - `results_summary.csv` - Model performance metrics
  - `predictions.csv` - All predictions for analysis
  - `predictions_train.png` - Training set visualization
  - `predictions_test.png` - Test set visualization
  - `feature_importance.png` - Feature importance plot

#### 8. **Code Organization**
- Original: Mixed concerns (data loading, preprocessing, modeling)
- Refactored: Clear separation of concerns with logical sections:
  1. Setup and data loading
  2. Data preprocessing
  3. Data splitting
  4. Model training
  5. Model evaluation
  6. Visualizations
  7. Results saving

---

## Reproducibility Features

### 1. **Seed Management**
- All random processes use explicit seeds (`RANDOM_SEED = 42`)
- Reproducible across different R versions and systems

### 2. **Version Control**
```bash
git status
git log --oneline
```

### 3. **Session Information**
- Captured at end of each run
- Includes R version, loaded packages, and system info

### 4. **Automated Environment Setup**
- Package installation from official CRAN repository
- Automatic data download on first run
- Clear output directory structure

---

## Running the Analysis

### Full Analysis
```powershell
# Run the complete pipeline
& "C:\Program Files\R\R-4.6.0\bin\R.exe" < src/main.R
```

### Unit Tests Only
```powershell
# Validate all functions work correctly
& "C:\Program Files\R\R-4.6.0\bin\R.exe" < tests/test_functions.R
```

### Install Dependencies
```powershell
# Install required packages
& "C:\Program Files\R\R-4.6.0\bin\R.exe" < src/requirements.R
```

---

## Analysis Workflow

### 1. Data Acquisition
- Downloads obesity dataset from UC Irvine ML Repository
- Extracts to `data/` directory
- Caches locally to avoid re-downloading

### 2. Data Preprocessing
- Separates web-scraped (498) and synthetic (thousands) records
- Calculates BMI from height/weight
- Classifies obesity levels: 0_underweight, 1_normal, 2_overweight, 3_obese
- Encodes categorical variables to numeric

### 3. Feature Engineering
- Selects 14 features for modeling
- Encodes transportation (binary)
- Encodes gender (binary)
- Encodes binary health indicators
- Encodes ordinal features (eating/alcohol frequency)

### 4. Model Training
- Uses Random Forest regressor
- Parameters: 100 trees, node size 5, max nodes 20
- 70% training / 30% test split

### 5. Evaluation
- Computes Mean Absolute Error (MAE) on BMI predictions
- Compares against baseline (mean of training data)
- Weights metrics by class to handle imbalance

---

## Output Files

After running, check `output/` for:

| File | Description |
|------|-------------|
| `results_summary.csv` | Model performance metrics (MAE, improvement %) |
| `predictions.csv` | All predictions with actuals for detailed analysis |
| `predictions_train.png` | Scatter plot of training predictions vs actual |
| `predictions_test.png` | Scatter plot of test predictions vs actual |
| `feature_importance.png` | Bar chart of feature importance |

---

## Coding Standards Applied

✓ **DRY (Don't Repeat Yourself)** - Reusable functions instead of copied code  
✓ **SOLID Principles** - Single responsibility, open/closed  
✓ **Clear Naming** - Function/variable names describe purpose  
✓ **Documentation** - Roxygen-style docstrings throughout  
✓ **Testing** - Unit tests validate core functionality  
✓ **Configuration** - Centralized constants, easy to modify  
✓ **Error Handling** - Input validation and informative messages  
✓ **Reproducibility** - Fixed seeds, package versions, session info  

---

## Requirements

- **R Version:** 4.6.0 or compatible
- **Required Packages:**
  - `httr` - HTTP requests
  - `readr` - CSV reading
  - `ggplot2` - Visualization (imported, not used in this version)
  - `randomForest` - Model training
- **Disk Space:** ~100MB for data download
- **Internet:** Required for initial data download

---

## Future Improvements

Potential enhancements following reproducible practices:

1. **Package Structure** - Convert to proper R package
2. **Testing Framework** - Use `testthat` for more robust testing
3. **Logging** - Implement logging system (e.g., `futile.logger`)
4. **Configuration Files** - Use YAML for external config
5. **Data Validation** - Add schema validation
6. **Documentation** - Generate with pkgdown or bookdown
7. **CI/CD** - Automated testing and validation
8. **Parallel Processing** - Speed up model training
9. **Model Comparison** - Test multiple algorithms
10. **Cross-validation** - Improved model evaluation

---

## References

- Original Dataset: [UC Irvine ML Repository](https://doi.org/10.24432/C5H31Z)
- Reproducible Research: [Peng et al., Science](https://doi.org/10.1126/science.1213847)
- R Best Practices: [Wickham & Bryan, R Packages](https://r-pkgs.org/)
# Assignment
Option A: pre-specificied dataset
Project Title: Coding Practical
Purpose: The aim of this project is to refactor and reuse the code provided in the assignment by applying the principles I have learnt in Reproducible Coding Practice.This priciples include modularity, documentation, testing, dependency management, version contol and FAIR software practice.
Installation instructions: 
* use the R version 4.0 or later
* Visual Studio Code
* Git
Data description: Data estimation of obesity levels based on eating habits and physical condition. 
How to run analyses:
Contact information:
