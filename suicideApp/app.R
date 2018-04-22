#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(plotly)
library(shinythemes)

dat <- readRDS("dat.RDS")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Suicide Stats Explorer"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30),
         selectInput("measureSelect",
                     "Select measure",
                     levels(dat$measure)),
         selectInput("yearSelect",
                     "Select year",
                     levels(dat$year))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotlyOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlotly({
     ggplotly(
      ggplot(filter(dat, measure == input$measureSelect & year == input$yearSelect), aes(x=category, y=rate)) +
        geom_bar(stat = "identity") +
        labs(
          y = "Rate per 10,000"
        ) +
        theme_classic()
      )
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

