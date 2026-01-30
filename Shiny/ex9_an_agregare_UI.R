ex9_an_agregare_UI <- function(id) {
  ns <- NS(id)
  
    tagList(
    titlePanel("Cerinta 9: Aproximarea Normala (Teorema Limita Centrala)"),
    
    sidebarLayout(
      sidebarPanel(
        h4("Configurare Simulare"),
        
        # alegerea tipului de analiza
        selectInput(ns("tip_agregat"), "Ce analizam?", 
                    choices = c("Profit Zilnic (Economic)" = "profit",
                                "Latenta Totala (Tehnic)" = "latenta")),
        
        hr(),
        
        # parametrii generali
        numericInput(ns("nr_zile"), "Numar zile simulate (N):", value = 365, min = 30, max = 5000),
        # folosim media din ex1 pentru input
        numericInput(ns("lambda_mediu"), "Media Clienti/Zi (Ex1):", value = 1000, min = 100),
        
        hr(),
        h5("Parametri Tehnici (din ex2/3)"),
        numericInput(ns("prob_succes_ag"), "Probabilitate Succes:", value = 0.95, min=0, max=1, step=0.01),
        numericInput(ns("medie_latenta_ag"), "Medie Latenta (ms):", value = 150),
        numericInput(ns("nr_max_retry_ag"), "Max Retry:", value = 3),
        
        # in cazul alegerii optiunii de profit se afiseaza parametrii economici
        # ATENTIE: Sintaxa speciala pentru conditionalPanel in module
        conditionalPanel(
          condition = paste0("input['", ns("tip_agregat"), "'] == 'profit'"),
          hr(),
          h5("Parametri Economici (din Ex11)"),
          numericInput(ns("castig_per_succes"), "Castig/Succes (RON):", value = 0.5, step=0.1),
          numericInput(ns("pierdere_per_churn"), "Pierdere/Churn (RON):", value = 50),
          numericInput(ns("prob_churn_q"), "Rata Churn (0-1):", value = 0.01, step=0.01),
          numericInput(ns("t_sla"), "Prag SLA (ms):", value = 500),
          numericInput(ns("penalitate_sla"), "Penalitate SLA (RON):", value = 2)
        ),
        
        hr(),
        actionButton(ns("btn_sim_agregat"), "Ruleaza Simularea", class = "btn-primary", width = "100%")
      ),
      
      mainPanel(
        tabsetPanel(
          # grafic principal
          tabPanel("Histograma & Distributie", 
                   br(),
                   plotOutput(ns("plot_histograma_agregat"), height = "400px"),
                   uiOutput(ns("interpretare_aproximare")) # concluzie
          ),
          
          # verificare vizuala
          tabPanel("Diagnostic (QQ Plot)", 
                   br(),
                   plotOutput(ns("plot_qq"), height = "400px"),
                   p("Daca punctele albastre urmaresc linia rosie, distributia este Normala.")
          )
        )
      )
    )
  )
}