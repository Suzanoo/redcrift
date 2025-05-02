model_ui <- function(){
  tabItem(tabName = "train_model",
          fluidPage(
            h3("Train Predictive Model"),
            fluidRow(
              column(6,
                     shinyWidgets::pickerInput("model_outcome", "Select Outcome Column", 
                                               choices = NULL, multiple = FALSE),
                     shinyWidgets::pickerInput("model_features", "Select Feature Columns", 
                                 choices = NULL, multiple = TRUE),
                     shinyWidgets::pickerInput("model_types", "Select Model(s)", 
                                 choices = c("Linear Regression" = "lm",
                                             "Support Vector Machine" = "svmRadial",
                                             "Random Forest" = "rf"),
                                 multiple = TRUE),
                     sliderInput("train_percent", "Training Data (%)", 
                                 min = 50, max = 90, value = 80, step = 5)
              ),
              column(6,
                     conditionalPanel(
                       condition = "input.model_types.includes('svmRadial')",
                       numericInput("svm_sigma", "SVM: Sigma", value = 0.1, min = 0.001, step = 0.01),
                       numericInput("svm_C", "SVM: Cost (C)", value = 1, min = 0.1, step = 0.1)
                     ),
                     conditionalPanel(
                       condition = "input.model_types.includes('rf')",
                       numericInput("rf_mtry", "Random Forest: mtry", value = 2, min = 1, step = 1)
                     ),
                     br(),
                     actionButton("train_model_btn", "Train Model", icon = icon("play"), class = "btn-success")
              )
            ),
            hr(),
            h4("Model Performance"),
            verbatimTextOutput("model_results"),
            
            hr(),
            fluidRow(
              column(6,
                     uiOutput("model_selector")
              ),
              column(6,
                     downloadButton("download_model", "Download Selected Model")
              )
            )
            
          )
          
          )
}



