library(tidyverse)
library(ggplot2)
library(lubridate)

load("metadata.RData")
save(metadata, "metadata.RData")

#############################################################################
# PLOT 1: ScaffoldN50 over Time (by Division)
#############################################################################
ggplot(data = metadata[metadata$submissiondate > "2010-01-01",],
       aes(x = submissiondate, 
           y = scaffoldn50,
           color = factor(Clade)
           )) + 
  geom_point() +
  facet_grid(~ Clade) + 
  geom_smooth(method = "lm", color = "black") +
  labs(title = "ScaffoldN50 Values Over the Past Decade",
       subtitle = "(Grouped by Division)",
       x = "")
  # geom_point(aes(color = factor(Division))) +
  # geom_smooth(aes(group = 1), method = "lm")

#############################################################################
# PLOT 2: ContigN50 over Time (by Division)
#############################################################################
subset_df = metadata[metadata$submissiondate > "2010-01-01" & 
                       metadata$contign50 < 5e+08,]
subset_df = subset_df[!is.na(subset_df$contign50),]
ggplot(data = subset_df,
       aes(x = submissiondate, 
           y = contign50,
           color = factor(Division)
       )) + 
  geom_point() +
  facet_grid(~ Division) + 
  geom_smooth(method = "lm", color = "black") + 
  labs(title = "ContigN50 Values Over the Past Decade",
       subtitle = "(Grouped by Division)",
       x = "")


