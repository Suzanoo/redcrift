# Load libraries
library(readr)
library(dplyr)
library(caret)


source("data.R")
source("utils.R")


# Split into training and testing data
set.seed(123)
trainIndex <- createDataPartition(data_model[[outcome_col]], p = 0.8, list = FALSE)
trainData_raw <- data_model[trainIndex, ]
testData_raw  <- data_model[-trainIndex, ]


# Encode (use label encoding here)
trainData <- label_encode(trainData_raw)
testData  <- label_encode(testData_raw)


# Train control
ctrl <- trainControl(method = "cv", number = 5)


# Define hyperparameters
tune_Length = 10


# Model 1: Random Forest
model_rf <- train(UnitCostPer_m2_THB ~ .,
                  data = trainData,
                  method = "rf",
                  trControl = ctrl,
                  tuneLength=tune_Length)


# Model 2: Linear Regression
model_lm <- train(UnitCostPer_m2_THB ~ .,
                  data = trainData,
                  method = "lm",
                  trControl = ctrl)


# Model 4: Support Vector Machine
model_svm <- train(UnitCostPer_m2_THB ~ .,
                   data = trainData,
                   method = "svmRadial",
                   trControl = ctrl,
                   preProcess = c("center", "scale"),
                   tuneLength=tune_Length)


# Evaluate on test set
models <- list(RF = model_rf, LM = model_lm, SVM = model_svm)
lapply(models, function(model) {
  pred <- predict(model, newdata = testData)
  postResample(pred, testData[[outcome_col]])
})


# Visualize variable importance
library(ggplot2)
imp <- varImp(model_rf)
ggplot(imp, top = 15) + ggtitle("Top 15 Important Variables - Random Forest")


# Log performance in a tidy table
performance <- lapply(models, function(model) {
  pred <- predict(model, newdata = testData)
  postResample(pred, testData[[outcome_col]])
})
do.call(rbind, performance)


# Save models
lapply(models, function(model) {
  saveRDS(model, paste0("models/model_", model$method, ".rds"))
})



