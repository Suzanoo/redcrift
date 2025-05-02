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
defalut_df <- data %>%
  select(all_of(c(feature_cols, outcome_col)))


# Data page UI
data_ui <- function() {
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
      )
}
