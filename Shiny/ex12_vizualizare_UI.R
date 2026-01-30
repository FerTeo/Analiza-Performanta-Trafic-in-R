
ex12_vizualizare_UI <- function(id) {
  ns <- NS(id)
  
  tagList(
    sidebarLayout(
      sidebarPanel(
        h4("Parametri Simulare (Ex 12)"),
        numericInput(ns("nr_sim_12"), "Numar Simulari", value = 1000, min = 100),
        
        h5("Parametri Sistem"),
        numericInput(ns("prob_succes_12"), "Probabilitate Succes (p)", value = 0.6, min = 0, max = 1, step = 0.05),
        numericInput(ns("max_retry_12"), "Max Retry", value = 3, min = 0),
        numericInput(ns("medie_lat_12"), "Medie Latenta (ms)", value = 50),
        numericInput(ns("sd_lat_12"), "Deviatie Std Latenta", value = 10),
        
        hr(),
        h5("Parametri Profit"),
        numericInput(ns("reward_success"), "Reward Succes (+)", value = 100),
        numericInput(ns("cost_time"), "Cost Timp (per ms) (-)", value = 0.5),
        numericInput(ns("cost_retry"), "Cost Retry (per incercare) (-)", value = 5),
        
        actionButton(ns("btn_sim_ex12"), "Simuleaza si Vizualizeaza", class = "btn-primary")
      ),
      
      mainPanel(
        tabsetPanel(
          tabPanel("Histograme",
                   br(),
                   h4("Distributiile pentru T si Profit"),
                   plotlyOutput(ns("plot_histograme"), height = "600px")
          ),
          tabPanel("Boxplot-uri (Conditionate)",
                   br(),
                   h4("Analiza Conditionata (Succes vs Esec)"),
                   p("Comparatia timpului de servire in functie de rezultatul final."),
                   plotlyOutput(ns("plot_boxplot"))
          ),
          tabPanel("Statistici & Interpretare",
                   br(),
                   h4("Tabel Statistici Descriptive"),
                   tableOutput(ns("statistici_detaliate")),
                   hr(),
                   uiOutput(ns("interpretare_ex12"))
          )
        )
      )
    )
  )
}
