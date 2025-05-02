# 🏗️ Construction Cost Prediction Dashboard

This Shiny web application helps you analyze construction project data, train custom machine learning models, and predict construction unit cost per square meter. It provides an intuitive interface for data upload, exploration, model training, and making predictions using saved models.

## 🚀 Features

- 📂 **Data Page**:
  - Upload your custom dataset (CSV).
  - Explore correlation or pairwise plots based on selected features.
  - View data summary and basic statistics.

- 🧠 **Model Page**:
  - Select features and outcome column.
  - Choose models: Linear Regression, SVM, XGBoost.
  - Customize hyperparameters (train-test split, tune length).
  - View training performance and download trained models.

- 🔮 **Predict Page**:
  - Upload a trained model file (`.rds`) from the Model page.
  - Dynamic input form based on model features.
  - Predict construction unit cost.
  - See prediction history with scrollable output table.

---

## 📦 Installation

```r
# Install required packages
install.packages(c("shiny", "dplyr", "readr", "caret", "e1071", "xgboost", 
                   "randomForest", "ggplot2", "GGally", "shinyWidgets", "DT"))

# Run the app
shiny::runApp("path_to_your_app_directory")

