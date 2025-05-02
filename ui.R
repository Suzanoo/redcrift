# UI
library(shinydashboard)

source("data.R")
source("model_ui.R")


ui <- dashboardPage(
  dashboardHeader(title = "Construction ML App"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data", tabName = "data", icon = icon("table")),
      menuItem("Train Model", tabName = "train_model", icon = icon("chart-bar")),
      menuItem("Predict", tabName = "predict", icon = icon("calculator"))
    )

  ),
  dashboardBody(
    tabItems(
      # Page 1: Data
      data_ui(),
      
      # Page 2: Model
      model_ui(),
      
      # Page 3: Prediction
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
