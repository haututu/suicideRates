# Overview
This project pulls together suicide statistics from PDFs online. I created an app to look through the statistics to be hosted on an open source NZ Shiny server. In the process I had to reshuffle the file structure so some directories in the code may be broken.

# Data extraction
In the `dataExtraction` folder the R script named `tabulizerTesting.R` pulls down all the data available on the the [MoJ website](https://coronialservices.justice.govt.nz/suicide/annual-suicide-statistics-since-2011/) and tidies it into a single long-format dataframe. The dataframe is outputted as `dat.RDS` where it can be queried.

# Navigating data
The `app.R` script is a basic shiny app to navigate the data. It has been deployed [here](https://shiny.nzoss.org.nz/suicide_statistics/).