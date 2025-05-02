## correlation plot
corr_plot <- function(data, label){
  if(label == "CORR"){
    data %>% GGally::ggcorr()
  }else{
    data %>% GGally::ggpairs()
  }
}