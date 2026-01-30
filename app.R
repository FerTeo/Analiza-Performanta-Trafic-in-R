# librarii
library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)

# surse scripturi
source("R/ex1_trafic.R")
source("R/ex2_latenta.R")
source("R/ex3_evenimente.R")
source("R/ex4_variabile_bidim_discrete.R")
source("R/ex5_variabile_bidim_discrete_si_continue.R")
source("R/ex9_an_agregare.R")
source("R/ex11_impact_economic.R")
source("R/ex6_conditionate.R")
source("R/ex7_dependenta.R")
source("R/ex8_inegalitati.R")
source("R/ex12_vizualizare.R")

# surse shiny
source("Shiny/ex1_trafic_UI.R")
source("Shiny/ex2_latenta_UI.R")
source("Shiny/ex3_evenimente_UI.R")
source("Shiny/ex4_variabile_bidim_discrete_UI.R")
source("Shiny/ex5_variabile_bidim_discrete_si_continue_UI.R")
source("Shiny/ex12_vizualizare_UI.R")
source("Shiny/ex9_an_agregare_UI.R")
source("Shiny/ex11_impact_economic_UI.R")
source("Shiny/ex6_conditionate_UI.R")
source("Shiny/ex7_dependenta_UI.R")
source("Shiny/ex8_inegalitati_UI.R")


# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("Analiza Performanta Trafic"),
  tabsetPanel(
    tabPanel("1. Trafic Zilnic", ex1_trafic_UI("ex1")),
    tabPanel("2. Timpi de Raspuns", ex2_latenta_UI("ex2")),
    tabPanel("3. Evenimente & Retry", ex3_evenimente_UI("ex3")),
    tabPanel("4. Variabile Bidimensionale Discrete", ex4_bidimensional_UI("ex4")),
    tabPanel("5. Variabile Bidimensionale Discrete (si continue)", ex5_corelatie_UI("ex5")),
    tabPanel("6. Conditionate", ex6_conditionate_UI("ex6")),
    tabPanel("7. Dependenta", ex7_dependenta_UI("ex7")),
    tabPanel("8. Inegalitati", ex8_inegalitati_UI("ex8"))
    tabPanel("9. Agregare & CLT", ex9_an_agregare_UI("ex9")),
    tabPanel("11. Impact Economic", ex11_impact_economic_UI("ex11")),
    tabPanel("12. Vizualizare Statistica", ex12_vizualizare_UI("ex12"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # id=ex1
  ex1_trafic_server("ex1")
  ex2_latenta_server("ex2")
  ex3_evenimente_server("ex3")
  ex4_bidimensional_server("ex4")
  ex5_corelatie_server("ex5")
  ex6_conditionate_server("ex6")
  ex7_dependenta_server("ex7")
  ex8_inegalitati_server("ex8")
  ex9_an_agregare_server("ex9")
  ex11_impact_economic_server("ex11")
  ex12_vizualizare_server("ex12")
}

# Run the application
shinyApp(ui = ui, server = server)
