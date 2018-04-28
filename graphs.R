library(ggplot2)
library(dplyr)

### Generate plot for the blog post

# Load data
dat <- readRDS("dat.RDS")

# Plot ethnicity over time
ethnicityPlot <- ggplot(filter(dat, measure == "ethnicity"), aes(x=year, y=rate, group=category, color=category)) +
  geom_point() +
  geom_line() +
  theme_classic() +
  theme(
    plot.background = element_rect(fill = "#ecf0f1", color=NA), 
    panel.background = element_rect(fill = "#ecf0f1"),
    legend.background = element_rect(fill = "#ecf0f1"),
    plot.title = element_text(hjust = 0.5)
  ) +
  labs(
    title="Suicide rate by ethnicity",
    y="Rate per 100,000",
    x="Year",
    color="Ethnicity"
  )

#Save the plots
ggsave("images/ethnicityPlot.svg", plot=ethnicityPlot, device="svg", width=7, height=4)
