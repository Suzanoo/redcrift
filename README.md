# Redcrift ML Prediction Dashboard

A Shiny web application for exploratory data analysis, training machine learning models, and making predictions on construction project cost per m².

## 🔧 Features
- Upload your dataset or use the default sample data.
- Explore data through tables, summaries, histograms, and correlation plots.
- Train multiple ML models (Linear Regression, SVM, Random Forest) with cross-validation.
- Customize model parameters.
- Download trained models in `.rds` format.
- Upload a trained model and make predictions from custom input forms.

## 📁 Project Structure
```
project/
│
├── app.R                 # Main Shiny app (UI and server)
├── utils.R               # Utility functions (label_encode, corr_plot, etc.)
├── data/
│   └── construction_data.csv  # Default dataset
```

## 🚀 How to Run
1. Clone the repository
```bash
git clone https://github.com/yourname/redcrift-dashboard.git
cd redcrift-dashboard
```
2. Install dependencies in R:
```r
install.packages(c("shiny", "shinydashboard", "readr", "dplyr", "ggplot2", 
                   "caret", "DT", "GGally", "shinyWidgets", "shinyjs"))
```
3. Run the app:
```r
shiny::runApp(".")
```

## 📈 Model Training
- Choose feature and outcome variables.
- Select ML algorithms.
- Customize parameters (SVM: Sigma/C, RF: mtry).
- Evaluate performance (RMSE, R², MAE).

## 🧠 Prediction Module
- Upload a previously trained model (`.rds`).
- App auto-generates input UI based on required features.
- Submit values to get predictions.
- View history of all predictions made.

## 📦 Model Compatibility
- Ensure feature names/types match the training data.
- You can use the same `label_encode()` logic in `utils.R` to preprocess prediction inputs.

## ✅ To-Do
- Add data validation for user-uploaded datasets.
- Add automatic feature selection or model tuning (e.g., using `caret::train()` with `tuneLength`).
- Add export to Excel/CSV for results.

---
