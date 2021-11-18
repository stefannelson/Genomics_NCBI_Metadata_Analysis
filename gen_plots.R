library(tidyverse)
library(ggplot2)
library(lubridate)
library(ggpubr)

source("plotting_methods.R")

load("metadata.RData")
save(metadata, "metadata.RData")

#############################################################################
# ScaffoldN50, ContigN50, and Coverage over time
#############################################################################
sub_df = filter_factor(metadata, "Carnivora", step = 2)
a1 = plot_v_time_scatter(sub_df, "scaffoldn50", factor = "Classification")
a2 = plot_v_time_scatter(sub_df, "contign50", factor = "Classification")
a3 = plot_v_time_scatter(sub_df, "coverage", factor = "Classification")

figure_a = ggarrange(a1,a2,a3, ncol = 1, nrow = 3, common.legend = TRUE, legend = "right")
annotate_figure(figure_a, top = text_grob("ScaffoldN50 and ContigN50 for Carnivora", size = 14))
# wilcox.test(as.numeric(sub_df$submissiondate), sub_df$scaffoldn50)



