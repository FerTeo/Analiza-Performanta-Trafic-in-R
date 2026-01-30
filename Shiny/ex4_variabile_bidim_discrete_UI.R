ex4_bidimensional_UI <- function(id) {
  ns <- NS(id) 
  
  tagList(
    sidebarLayout(
      sidebarPanel(
        h4("Configurare (N, F)"),
        numericInput(ns("prob_succes"), "Probabilitate Succes (p)", 0.4, 0.01, 1, 0.05),
        numericInput(ns("max_retry"), "Nr. Max Retry", 3, 0, 10),
        numericInput(ns("nr_sim"), "Nr. Simulari", 5000, 100, 100000),
        actionButton(ns("btn_sim_nf"), "Genereaza Distributia", class="btn-primary")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Distributie Comuna", 
                   br(),
                   plotlyOutput(ns("plot_comun"))
          ),
          tabPanel("Marginale", 
                   br(),
                   plotOutput(ns("plot_marginale"))
          ),
          tabPanel("Test Independenta", 
                   verbatimTextOutput(ns("rezultat_test")),
                   uiOutput(ns("interpretare_test"))
          )
        )
      )
    )
  )
}