ex5_corelatie_UI <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        h4("Configurare (N, T)"),
        numericInput(ns("prob_succes"), "Probabilitate Succes (p)", 0.5, 0.01, 1),
        numericInput(ns("max_retry"), "Nr. Max Retry", 3, 0, 10),
        numericInput(ns("medie_lat"), "Latenta Medie (ms)", 50, 1),
        numericInput(ns("sd_lat"), "Deviatie Latenta", 10, 0),
        numericInput(ns("nr_sim"), "Nr. Simulari", 1000, 100, 10000),
        actionButton(ns("btn_sim_nt"), "Simuleaza si Analizeaza", class="btn-primary")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Grafic (N vs T)",
                   br(),
                   plotlyOutput(ns("plot_nt")),
                   helpText("Boxplot-ul arata distributia timpului total pentru fiecare numar de incercari.")
          ),
          tabPanel("Statistici & Corelatie",
                   br(),
                   tableOutput(ns("statistici_nt")),
                   hr(),
                   uiOutput(ns("interpretare_nt"))
          )
        )
      )
    )
  )
}