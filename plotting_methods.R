library(tidyverse)
library(ggplot2)
library(lubridate)
library(gridExtra)

plot_v_time_scatter = function(df, column, factor = "Lineage",
                               title = "", subtitle = "") {
  # GGplot -> date on x-axis, arbitrary y-axis
  # Data is subset 
  df = df %>% filter(submissiondate >= "2010-01-01")
  
  Classification = factor(df[,factor])
  
  a = ggplot(data = df,
             aes(x = submissiondate, 
                 y = df[,column],
                color = Classification)) + 
    geom_point() +
    #facet_grid(~ factor(df[,factor])) + 
    geom_smooth(color = "black", alpha = 0.5) +
    labs(title = title, subtitle = subtitle, x = "", y = column) 
  
  return(a)
}

filter_factor = function (df, search_term = "", step = 1, search_col = "Lineage") {
  # Subset the passed in dataframe by search term in Lineage (default)
  sub_df = df[grep(search_term, df[,search_col]),]
  if (search_col == "Lineage") {
    col = c()
    for (i in 1:nrow(sub_df)) {
      lineage_path = unlist(strsplit(sub_df[i, "Lineage"], "; "))
      classification = lineage_path[grep(search_term, lineage_path)+step]
      col = c(col, classification)
    }
    sub_df$Classification = col
  }
  return(sub_df)
}

