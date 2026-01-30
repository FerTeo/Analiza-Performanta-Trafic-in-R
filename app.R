# librarii
library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)

# surse scripturi
source("R/ex1_trafic.R")
source("R/ex2_latenta.R")
source("R/ex3_evenimente.R")
source("R/ex9_an_agregare.R")
source("R/ex11_impact_economic.R")

# surse shiny
source("Shiny/ex1_trafic_UI.R")
source("Shiny/ex2_latenta_UI.R")
source("Shiny/ex3_evenimente_UI.R")
source("Shiny/ex9_an_agregare_UI.R")
source("Shiny/ex11_impact_economic_UI.R")
# Define UI for application that draws a histogram
ui <- fluidPage(
  tabsetPanel(
    tabPanel("1. Trafic Zilnic", ex1_trafic_UI("ex1")),
    tabPanel("2. Timpi de Raspuns", ex2_latenta_UI("ex2")),
    tabPanel("3. Evenimente & Retry", ex3_evenimente_UI("ex3")),
    tabPanel("9. Agregare & CLT", ex9_an_agregare_UI("ex9")),
    tabPanel("11. Impact Economic", ex11_impact_economic_UI("ex11"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # id=ex1
  ex1_trafic_server("ex1")
  ex2_latenta_server("ex2")
  ex3_evenimente_server("ex3")
  ex9_an_agregare_server("ex9")
  ex11_impact_economic_server("ex11")
}

# Run the application
shinyApp(ui = ui, server = server)
