#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(ggplot2)
library(plotly)
library(shinythemes)

dat <- readRDS("dat.RDS")

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  useShinyjs(),
  # Application title
  titlePanel("Suicide Stats Explorer"),
  
  p("Suicide statistics are difficult to access online. 
    This app allows you to 'slice 'n dice' these stats in one place. 
    It is a very early development version so likely to change substantially."),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      radioButtons("viewSelect",
                   "Select view mode",
                   c("Time series", "Cross section")),
      selectInput("measureSelect",
                  "Select measure",
                  levels(dat$measure)),
      uiOutput("yearSelect"),
      uiOutput("categorySelect"),
      
        
      actionButton("email", "Contact author")
      
      ),
    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("distPlot")
      )
    )
  )

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  observe({
    if(input$viewSelect == "Time series") {
      show("categorySelect", anim = TRUE, time = 1) 
      hide("yearSelect", anim = TRUE)
    } else {
      hide("categorySelect", anim = TRUE) 
      show("yearSelect", anim = TRUE, time = 1)
    }
  })
  
  output$yearSelect <- renderUI({
    choices <- levels(
      droplevels(
        filter(dat, measure == input$measureSelect)$year
      )
    )
    
    selectInput("yearSelect",
                "Select year",
                choices = choices)
  })
  
  output$categorySelect <- renderUI({
    
    choices <- levels(
      droplevels(
        filter(dat, measure == input$measureSelect)$category
        )
      )
    
    selectInput("categorySelect",
                "Select category",
                choices = choices,
                multiple = TRUE,
                selected = choices[1])
    })
   
  output$distPlot <- renderPlotly({
     if (input$viewSelect == "Cross section") {
       ggplotly(
         ggplot(filter(dat, 
                       measure == input$measureSelect & 
                         year == input$yearSelect &
                         category != "Off Shore"), 
                aes(x=category, y=rate)) +
           geom_bar(stat = "identity") +
           labs(
             y = "Rate per 100,000"
           ) +
           theme_classic() +
           theme(
             axis.text.x = element_text(angle = 45, hjust = 1)
           )
       ) 
     } else {
       ggplotly(
         ggplot(filter(dat, 
                       measure == input$measureSelect & 
                         category %in% input$categorySelect &
                         category != "Off Shore"), 
                aes(x=year, y=rate, group=category, color=category)) +
           geom_point() +
           geom_line() +
           labs(
             y = "Rate per 100,000"
             ) +
           theme_classic() +
           theme(
             axis.text.x = element_text(angle = 45, hjust = 1)
           )
         )
       }
    })
   
}

# Run the application 
shinyApp(ui = ui, server = server)

