
#librarii
library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)

#surse scripturi
source("R/ex1_trafic.R")

#surse shiny
source("Shiny/ex1_trafic_UI.R")






# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Analiza Trafic"),
    
    #ex1 este id-ul
    ex1_trafic_UI("ex1")
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {

    #id=ex1
    ex1_trafic_server("ex1")
}

# Run the application 
shinyApp(ui = ui, server = server)
