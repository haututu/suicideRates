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
  
  HTML('<p>Suicide statistics are difficult to access online. 
    This app allows you to slice `n dice suicide stats found in PDFs on the <a href="https://coronialservices.justice.govt.nz/suicide/annual-suicide-statistics-since-2011/">Ministry of Justice website</a>. 
    It is a very early development version so likely to change substantially. 
    Hit the contact button below and fire any feedback or questions my way.</p>'),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      radioButtons("viewSelect",
                   "Select view mode",
                   c("Time series", "Cross section")),
      
      radioButtons("varSelect",
                   "Select variable",
                   c("rate", "num")),
      
      selectInput("measureSelect",
                  "Select measure",
                  levels(dat$measure)),
      
      uiOutput("yearSelect"),
      
      uiOutput("categorySelect"),
        
      a(actionButton("email", 
                   "Contact Author",
                   icon = icon("envelope")),
        href="mailto:taylor.winter00@gmail.com?Subject=Suicide%20app")
      
      ),
    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("distPlot")
      )
    ),
  
  HTML('<p><b>Please note</b> if you or someone you know is suffering and considering suicide then
       <a href="https://www.mentalhealth.org.nz/get-help/in-crisis/helplines/">follow this link now</a> for help.</p>')
  )

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  eventReactive(input$email,
                {HTML('<a href="mailto:someone@example.com?Subject=Hello%20again" target="_top"></a>')})
  
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
    
     y <- ifelse(input$varSelect == "rate",
                 "Rate per 100,000",
                 "Total count"
                 )
    
     if (input$viewSelect == "Cross section") {
       ggplotly(
         ggplot(filter(dat, 
                       measure == input$measureSelect & 
                         year == input$yearSelect &
                         category != "Off Shore"), 
                aes_string(x="category", y=input$varSelect)) +
           geom_bar(stat = "identity") +
           labs(
             y = y
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
                aes_string(x="year", y=input$varSelect, group="category", color="category")) +
           geom_point() +
           geom_line() +
           labs(
             y = y
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

