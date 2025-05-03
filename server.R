library(shiny)
library(caret)
library(DT)
library(ggplot2)
library(GGally)
source("utils.R")


# --------------------- Default --------------------- 
# Read and clean the data
data <- read_csv("data/construction_data.csv")


# Define feature columns and outcome
feature_cols <- c(
  "Type", "LocationType", "LuxuryLevel", "TotalFloorArea_m2",
  "NumberOfFloors", "NumberOfBasements", "FoundationType",
  "StructureType", "DurationDays", "ContractType",
  "StartYear", "SeasonStart", "AccessCondition"
)


outcome_col <- "UnitCostPer_m2_THB"


# Keep only features and outcome in data
default_df <- data %>%
  select(all_of(c(feature_cols, outcome_col)))


# --------------------- Server Logic --------------------- 

server <- function(input, output, session) {
  
  # --------------------- Predict  page ---------------------
  
  input_values <- reactiveValues(history = data.frame())
  
  # Store uploaded model and extracted metadata
  predict_model_info <- reactiveValues(
    model = NULL,
    features = NULL,
    outcome = NULL,
    history = data.frame()
  )
  
  
  # Load uploaded model and extract features/outcome
  observeEvent(input$upload_model_file, {
    req(input$upload_model_file)
    
    model_path <- input$upload_model_file$datapath
    model <- readRDS(model_path)
    
    # Extract formula from model
    form <- formula(model)
    outcome <- all.vars(form)[1]
    features <- all.vars(form)[-1]
    
    # Store
    predict_model_info$model <- model
    predict_model_info$features <- features
    predict_model_info$outcome <- outcome
  })
  
  
  # Generate input fields from model features
  output$input_ui <- renderUI({
    req(predict_model_info$model, predict_model_info$features)
    df <- reactive_data()
    
    lapply(predict_model_info$features, function(col) {
      vals <- unique(df[[col]])
      if (is.numeric(df[[col]])) {
        numericInput(col, label = col, value = round(mean(vals, na.rm = TRUE), 2))
      } else {
        selectInput(col, label = col, choices = vals)
      }
    })
  })
  
  
  # Predict button logic
  observeEvent(input$predict_btn, {
    req(predict_model_info$model)
    
    features <- predict_model_info$features
    outcome <- predict_model_info$outcome
    input_list <- lapply(features, function(col) input[[col]])
    names(input_list) <- features
    input_data <- as.data.frame(input_list, stringsAsFactors = FALSE)
    
    # Format input
    input_data <- input_data %>%
      mutate(across(where(is.character), as.factor))
    
    input_encoded <- label_encode(input_data)
    
    # Predict
    pred <- predict(predict_model_info$model, newdata = input_encoded)
    
    output$prediction_output <- renderPrint({
      cat("Prediction:", round(pred, 2), outcome)
    })
    
    # Record history
    new_row <- input_data
    new_row$Prediction <- pred
    predict_model_info$history <- rbind(predict_model_info$history, new_row)
  })
  
  # History table
  output$history_table <- DT::renderDataTable({
    DT::datatable(
      predict_model_info$history,
      options = list(scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  
  # --------------------- Data page ---------------------
  
  # Reactive: Loaded dataset (default or uploaded)
  reactive_data <- reactive({
    if (input$use_uploaded && !is.null(input$uploaded_data)) {
      tryCatch({
        read_csv(input$uploaded_data$datapath)
      }, error = function(e) {
        showNotification("Failed to read uploaded file", type = "error")
        return(NULL)
      })
    } else {
      default_df  # default data from script
    }
  })
  
  
  # Display Table
  output$data_table <- DT::renderDataTable({
    req(reactive_data())
    DT::datatable(
      reactive_data(),
      options = list(scrollX = TRUE),
      rownames = FALSE)
  })
  
  
  # Data Summary
  output$data_summary <- renderPrint({
    req(reactive_data())
    if (!is.null(input$selected_features)) {
      summary(reactive_data()[, input$selected_features, drop = FALSE])
    } else {
      summary(reactive_data())
    }
  })
  
  
  # Feature Distribution Plot
  observe({
    updateSelectInput(session, "dist_var", choices = names(reactive_data()))
  })
  
  output$dist_plot <- renderPlot({
    req(input$dist_var)
    var <- reactive_data()[[input$dist_var]]
    if (is.numeric(var)) {
      hist(var, main = paste("Histogram of", input$dist_var), col = "lightblue")
    } else {
      barplot(table(var), main = paste("Barplot of", input$dist_var), col = "lightgreen")
    }
  })
  
  
  ## Correlation
  # Select features to see correlation
  observe({
    numeric_cols <- names(Filter(is.numeric, reactive_data()))
    shinyWidgets::updatePickerInput(session, "selected_features", choices = numeric_cols)
  })
  
  
  # Enable/Disable the actionButton
  observe({
    toggleState("plot_corr", !is.null(input$selected_features) && length(input$selected_features) > 1)
  })
  
  
  # Reactive correlation data subset
  selected_corr_data <- eventReactive(input$plot_corr, {
    req(input$selected_features)
    reactive_data()[, input$selected_features, drop = FALSE]
  })
  
  
  # Plot
  output$corr_plot <- renderPlot({
    corr_plot(selected_corr_data(), input$corr_type)
  })
  
  
  # reset input to initial(NULL) if new file have been upload .
  # app cannot render graph(Error was managed)
  observeEvent(input$file_upload, {
    shinyjs::reset("selected_features")
  })
  
  
  # --------------------- Train Model page ---------------------
  
  #  Update Feature Picker Dynamically Based on Outcome
  observe({
    req(reactive_data())
    all_cols <- names(reactive_data())
    
    shinyWidgets::updatePickerInput(session, "model_outcome", choices = all_cols)
  })
  
  observeEvent(input$model_outcome, {
    req(reactive_data(), input$model_outcome)
    all_cols <- names(reactive_data())
    feature_choices <- setdiff(all_cols, input$model_outcome)
    
    shinyWidgets::updatePickerInput(session, "model_features", choices = feature_choices)
  })
  
  
  ## ----- ML -----
  # Store trained models
  trained_models <- reactiveVal(list())
  model_metrics <- reactiveVal(data.frame())
  
  
  # Trainning Logic
  observeEvent(input$train_model_btn, {
    req(input$model_features, input$model_outcome, input$model_types)
    
    # Prepare data
    df <- reactive_data()[, c(input$model_features, input$model_outcome)]
    df_encoded <- label_encode(df)
    
    features <- input$model_features
    outcome <- input$model_outcome
    form <- as.formula(paste(outcome, "~ ."))
    
    # Train/test split
    set.seed(123)
    idx <- createDataPartition(df_encoded[[outcome]], p = input$train_percent / 100, list = FALSE)
    train_df <- df_encoded[idx, ]
    test_df  <- df_encoded[-idx, ]
    
    # Train selected models with parameters
    ctrl <- trainControl(method = "cv", number = 5)
    trained <- list()
    results <- data.frame(Model = character(), RMSE = numeric(), Rsquared = numeric(), MAE = numeric())
    
    withProgress(message = "Training Models...", value = 0, {
      n <- length(input$model_types)
      for (i in seq_along(input$model_types)) {
        method <- input$model_types[i]
        incProgress(1 / n, detail = paste("Training", method))
        
        tuneGrid <- NULL
        if (method == "svmRadial") {
          tuneGrid <- expand.grid(sigma = input$svm_sigma, C = input$svm_C)
          
        }
        if (method == "xgbTree") {
          tuneGrid <- expand.grid(nrounds = input$xgb_nrounds,
                                  eta = input$xgb_eta,
                                  max_depth = 6, gamma = 0,
                                  colsample_bytree = 0.8,
                                  min_child_weight = 1,
                                  subsample = 0.8)
        }
        if (method == "knn") {
          tuneGrid <- expand.grid(k = input$knn_k)
          
        }
        else if (method == "rf") {
          tuneGrid <- expand.grid(mtry = input$rf_mtry)
          
        }
        
        model <- caret::train(form, data = train_df, method = method,
                              trControl = ctrl,
                              tuneGrid = tuneGrid,
                              tuneLength = if (is.null(tuneGrid)) 5 else NULL)
        
        
        
        pred <- predict(model, newdata = test_df)
        perf <- postResample(pred, test_df[[outcome]])
        
        results <- rbind(results, data.frame(
          Model = method,
          RMSE = perf["RMSE"],
          Rsquared = perf["Rsquared"],
          MAE = perf["MAE"]
        ))
        
        trained[[method]] <- model
      }
    })
    
    # Save models and metrics
    trained_models(trained)
    model_metrics(results)
  })
  
  # Render result table
  output$model_results <- renderPrint({
    req(model_metrics())
    print(model_metrics(), row.names = FALSE)
  })
  
  # Populate download dropdown
  output$model_selector <- renderUI({
    req(trained_models())
    selectInput("model_to_download", "Select Model to Download", choices = names(trained_models()))
  })
  
  # Download handler
  output$download_model <- downloadHandler(
    filename = function() {
      paste0(input$model_to_download, "_model.rds")
    },
    content = function(file) {
      req(input$model_to_download)
      saveRDS(trained_models()[[input$model_to_download]], file)
    }
  )
}
