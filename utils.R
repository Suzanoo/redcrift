one_hot_encode <- function(data) {
  non_numeric_cols <- sapply(data, function(x) !is.numeric(x))
  non_numeric_data <- data[, non_numeric_cols]
  numeric_data <- data[, !non_numeric_cols]
  
  encoded_data <- numeric_data
  
  for (col in colnames(non_numeric_data)) {
    encoded_cols <- model.matrix(~ 0 + factor(non_numeric_data[[col]]))
    colnames(encoded_cols) <- paste(col, levels(factor(non_numeric_data[[col]])), sep = "_")
    encoded_data <- cbind(encoded_data, encoded_cols)
  }
  
  return(encoded_data)
}



label_encode <- function(data) {
  non_numeric_cols <- sapply(data, function(x) !is.numeric(x))
  non_numeric_data <- data[, non_numeric_cols]
  numeric_data <- data[, !non_numeric_cols]
  
  encoded_data <- numeric_data
  
  for (col in colnames(non_numeric_data)) {
    encoded_data[[col]] <- as.numeric(factor(non_numeric_data[[col]]))
  }
  
  return(encoded_data)
}


## correlation plot
corr_plot <- function(data, label){
  if(label == "CORR"){
    data %>% GGally::ggcorr()
  }else{
    data %>% GGally::ggpairs()
  }
}


