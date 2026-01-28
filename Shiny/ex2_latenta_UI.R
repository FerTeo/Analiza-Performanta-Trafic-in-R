# UI pentru exercitiul 2

ex2_latenta_UI <- function(id) {
  ns <- NS(id)
  
  tagList(
    fluidRow(
      column(4,
             wellPanel(
               h4("Configurare Latenta (S)"),
               helpText("S reprezinta timpul de raspuns per cerere."),
               
               selectInput(ns("dist_tip"), "Tip Distributie:",
                           choices = c("Gamma", "Normala")),
               
               # parametrii se schimba dinamic in functie de selectie
               uiOutput(ns("ui_parametri")),
               
               actionButton(ns("btn_sim_latenta"), "Simuleaza Latenta", 
                            class = "btn-primary", icon = icon("play"))
             )
      ),
      column(8,
             tabsetPanel(
               tabPanel("Grafic Densitate", 
                        plotOutput(ns("plot_latenta"))),
               tabPanel("Statistici", 
                        br(),
                        tableOutput(ns("tabel_statistici_latenta")),
                        br(),
                        uiOutput(ns("text_interpretare_statistici"))),
               tabPanel("Interpretare", 
                        uiOutput(ns("interpretare_text")))
             )
      )
    )
  )
}

