ex11_impact_economic_UI <- function(id) {
  ns <- NS(id)
  
  tagList(
    titlePanel("Cerinta 11: Impact Economic si Analiza Cost-Beneficiu"),
    
    sidebarLayout(
      sidebarPanel(
        h4("1. Parametri Tehnici (Sistem)"),
        numericInput(ns("lambda"), "Trafic Mediu (Clienti/Zi):", 1000, step=100),
        sliderInput(ns("prob_succes"), "Rata Succes Tehnic (%):", 90, 100, 98, step=0.1),
        numericInput(ns("latenta"), "Latenta Medie (ms):", 150),
        
        hr(),
        h4("2. Parametri Economici (Business)"),

        numericInput(ns("pret"), "Castig per Request (RON):", 0.5, step=0.1),
        numericInput(ns("cost_churn"), "Cost Pierdere Client (RON):", 50),
        
        h5("Politica SLA"),
        numericInput(ns("sla_limit"), "Limita Timp SLA (ms):", 500),
        numericInput(ns("sla_penalty"), "Penalitate SLA (RON):", 2),
        
        hr(),
        actionButton(ns("btn_calc_eco"), "Calculeaza Profitabilitatea", 
                     class = "btn-success", width = "100%")
      ),
      
      mainPanel(
        # Randul 1: Rezumat Rapid
        fluidRow(
          column(4, wellPanel(h4("Profit Mediu Zilnic"), h3(textOutput(ns("txt_medie")), style="color:blue"))),
          column(4, wellPanel(h4("Risc de Pierdere"), h3(textOutput(ns("txt_risc")), style="color:red"))),
          column(4, wellPanel(h4("Profit Total (Anual)"), h3(textOutput(ns("txt_total")), style="color:green")))
        ),
        
        br(),
        
        tabsetPanel(
          # Grafic Evolutie
          tabPanel("Evolutie & Distributie", 
                   h4("Evolutia Profitului in Timp"),
                   plotOutput(ns("plot_evolutie"), height = "250px"),
                   hr(),
                   h4("Distributia Profitului (Histograma)"),
                   plotOutput(ns("plot_hist"), height = "250px")
          ),
          
          # Analiza Compromis
          tabPanel("Analiza Compromis (Trade-off)",
                   br(),
                   h4("Explicatie Compromis Tehnico-Economic"),
                   uiOutput(ns("explicatie_tradeoff")),
                   br(),
                   p("Joaca-te cu sliderul 'Rata Succes' si 'Latenta'. Vei observa ca:"),
                   tags$ul(
                     tags$li("Daca imbunatatesti sistemul (cresti succesul/scazi latenta), costurile tehnice scad."),
                     tags$li("Daca penalitatea SLA e mare, merita sa investesti in servere rapide."),
                     tags$li("Daca costul de Churn e mare (50 RON), chiar si 1% erori distrug profitul.")
                   )
          )
        )
      )
    )
  )
}