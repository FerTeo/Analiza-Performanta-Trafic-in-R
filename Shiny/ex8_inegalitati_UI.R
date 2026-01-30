# Ex 8: UI & Server
source("R/ex8_inegalitati.R")
source("R/ex3_evenimente.R") # pentru date

ex8_inegalitati_UI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            column(4,
                wellPanel(
                    h4("Inegalitati Probabilistice"),
                    numericInput(ns("nr_simulari"), "Numar Simulari", 5000, min=100),
                    numericInput(ns("medie_latenta"), "Latenta (ms)", 100),
                    hr(),
                    h5("Parametri Verificare:"),
                    numericInput(ns("prag_markov"), "Prag Markov (a)", 200),
                    numericInput(ns("k_cebisev"), "Deviatii Cebisev (k)", 2),
                    actionButton(ns("btn_check"), "Verifica Inegalitati", class="btn-success")
                )
            ),
            column(8,
                h3("Rezultate Verificare"),
                uiOutput(ns("ui_rezultate"))
            )
        )
    )
}

ex8_inegalitati_server <- function(id) {
    moduleServer(id, function(input, output, session) {
        
        rezultate <- eventReactive(input$btn_check, {
            # generam date
            df <- simuleaza_evenimente(input$nr_simulari, 0.5, input$medie_latenta, 3) # p_succes 0.5 fix pt simplitate aici
            
            verificare_inegalitati(df, input$prag_markov, input$k_cebisev)
        })
        
        output$ui_rezultate <- renderUI({
            res <- rezultate()
            req(res)
            
            # helper pt culoare
            color_bool <- function(val) if(val) "green" else "red"
            
            tagList(
                h4("1. Markov"),
                p(HTML(paste0("P(T >= a) <= E[T] / a <br>",
                              "<b>Empiric:</b> ", round(res$Markov$Empiric_P_Mare, 4), 
                              " <= <b>Teoretic:</b> ", round(res$Markov$Limita_Teoretica, 4),
                              " -> <span style='color:", color_bool(res$Markov$Respectat), "'>", res$Markov$Respectat, "</span>"))),
                hr(),
                h4("2. Cebisev"),
                p(HTML(paste0("P(|T - E[T]| >= k*sd) <= 1/k^2 <br>",
                              "<b>Empiric:</b> ", round(res$Cebisev$Empiric_P_Outlier, 4), 
                              " <= <b>Teoretic:</b> ", round(res$Cebisev$Limita_Teoretica, 4),
                              " -> <span style='color:", color_bool(res$Cebisev$Respectat), "'>", res$Cebisev$Respectat, "</span>"))),
                hr(),
                h4("3. Jensen (pentru x^2)"),
                p(HTML(paste0("(E[T])^2 <= E[T^2] <br>",
                              "<b>Stanga:</b> ", round(res$Jensen$Patratul_Mediei, 2), 
                              " <= <b>Dreapta:</b> ", round(res$Jensen$Media_Patratelor, 2),
                              " -> <span style='color:", color_bool(res$Jensen$Respectat), "'>", res$Jensen$Respectat, "</span>")))
            )
        })
    })
}
