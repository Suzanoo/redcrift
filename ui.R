library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "Redcrift Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data", tabName = "data", icon = icon("table")),
      menuItem("Train Model", tabName = "train_model", icon = icon("cogs")),
      menuItem("Predict", tabName = "predict", icon = icon("calculator"))
    )

  ),
  dashboardBody(
    tabItems(
      # ---------- Page 1: Data ---------
      tabItem(tabName = "data",
              tabPanel("Data",
                       sidebarLayout(
                         sidebarPanel(
                           fileInput("uploaded_data", "Upload your CSV data",
                                     accept = c(".csv")),
                           checkboxInput("use_uploaded", "Use uploaded data instead of default", FALSE),
                           tags$hr(),
                           helpText("Make sure your uploaded file has the same column structure as the original data.")
                         ),
                         mainPanel(
                           DT::dataTableOutput("data_table")
                         )
                       )
              ),
              
              fluidRow(
                box(title = "Dataset", width = 12,
                    DT::dataTableOutput("data_table"))
              ),
              
              # Data summary
              fluidRow(
                box(title = "Data Summary", width = 12,
                    verbatimTextOutput("data_summary"))
              ),
              
              # Feature Distribution Plot
              fluidRow(
                box(title = "Feature Distribution", width = 12,
                    selectInput("dist_var",
                                "Select Variable for Distribution:",
                                choices = NULL),
                    plotOutput("dist_plot"))
              ),
              
              # Correlation
              fluidRow(
                box(title = "Correlation", width = 12,
                    shinyWidgets::pickerInput(
                      inputId = "selected_features",
                      label = "Select numeric features:",
                      choices = NULL,  # dynamically set in server
                      multiple = TRUE,
                      options = shinyWidgets::pickerOptions(
                        actionsBox = TRUE,
                        liveSearch = TRUE,
                        size = 10
                      )
                    ),
                    radioButtons("corr_type", "Correlation Type", choices = c("CORR", "PAIR"), inline = TRUE),
                    actionButton("plot_corr", "Render Correlation Plot"),
                    plotOutput("corr_plot"),
                )
              ),
      ),
      
      # ---------- Page 2: Model ----------
      tabItem(tabName = "train_model",
              fluidPage(
                h3("Select features and outcome"),      
                fluidRow(
                  column(6,
                         shinyWidgets::pickerInput("model_outcome", "Select Outcome Column", 
                                                   choices = NULL, multiple = FALSE),
                         shinyWidgets::pickerInput("model_features", "Select Feature Columns", 
                                                   choices = NULL, multiple = TRUE,
                                                   options = list(`actions-box` = TRUE)
                         )
                  )
                ),
                h3("Train Predictive Model"),
                fluidRow(
                  column(6,
                         shinyWidgets::pickerInput("model_types", "Select Model(s)", 
                                                   choices = c("Linear Regression" = "lm",
                                                               "Support Vector Machine" = "svmRadial",
                                                               "Random Forest" = "rf",
                                                               "Extreme Gradient Boosting" = "xgbTree",
                                                               "k-Nearest Neighbors" = "knn"
                                                   ),
                                                   multiple = TRUE),
                         sliderInput("train_percent", "Training Data (%)", 
                                     min = 50, max = 90, value = 80, step = 5)
                  ),
                  column(6,
                         # SVM Hyperparameters
                         conditionalPanel(
                           condition = "input.model_types.includes('svmRadial')",
                           numericInput("svm_sigma", "SVM: Sigma", value = 0.1, min = 0.001, step = 0.01),
                           numericInput("svm_C", "SVM: Cost (C)", value = 1, min = 0.1, step = 0.1)
                         ),
                         # RF Hyperparameters
                         conditionalPanel(
                           condition = "input.model_types.includes('rf')",
                           numericInput("rf_mtry", "Random Forest: mtry", value = 2, min = 1, step = 1)
                         ),
                         # XGBoost Hyperparameters
                         conditionalPanel(
                           condition = "input.model_types.includes('xgbTree')",
                           numericInput("xgb_nrounds", "XGBoost: nrounds", value = 100, min = 10),
                           numericInput("xgb_eta", "XGBoost: eta (learning rate)", value = 0.1, min = 0.01, step = 0.01)
                         ),
                         conditionalPanel(
                           condition = "input.model_types.includes('xgbTree')",
                           numericInput("xgb_nrounds", "XGBoost: nrounds", value = 100, min = 10),
                           numericInput("xgb_eta", "XGBoost: eta (learning rate)", value = 0.1, min = 0.01, step = 0.01),
                           numericInput("xgb_maxdepth", "XGBoost: max_depth", value = 3, min = 1),
                           sliderInput("xgb_iterations", "Trees used in prediction (iteration_range)", min = 1, max = 100, value = 100)
                         ),
                         # k-NN Hyperparameter
                         conditionalPanel(
                           condition = "input.model_types.includes('knn')",
                           numericInput("knn_k", "KNN: k", value = 5, min = 1)
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
      ),
      
      # ---------- Page 3: Prediction ----------
      tabItem(tabName = "predict",
              fluidRow(
                box(
                  title = "Upload Trained Model (.rds)", status = "danger", solidHeader = TRUE, width = 12,
                  fileInput("upload_model_file", "Choose model file", accept = ".rds")
                ),
                box(
                  title = "Prediction Input", status = "primary", solidHeader = TRUE,
                  width = 12,
                  uiOutput("input_ui"),
                  actionButton("predict_btn", "Predict", class = "btn btn-success")
                ),
                box(
                  title = "Prediction Result", status = "info", solidHeader = TRUE,
                  verbatimTextOutput("prediction_output")
                ),
                box(
                  title = "Prediction History", status = "warning", solidHeader = TRUE,
                  width = 12,
                  DT::dataTableOutput("history_table")
                )
              )
      )
      
    )
  )
)
