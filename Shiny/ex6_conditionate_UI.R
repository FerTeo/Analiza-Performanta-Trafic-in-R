source("R/ex3_evenimente.R") 
source("R/ex6_conditionate.R")

ex6_conditionate_UI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            column(4,
                wellPanel(
                    h4("Calcul Conditionate"),
                    numericInput(ns("nr_simulari"), "Numar Simulari", 5000, min=100),
                    numericInput(ns("p_succes"), "Probabilitate Succes", 0.6, min=0.01, max=1, step=0.05),
                    numericInput(ns("medie_latenta"), "Medie Latenta (ms)", 100, min=1),
                    numericInput(ns("nr_max_retry"), "Max Retry", 3, min=0),
                    hr(),
                    h5("Conditii:"),
                    numericInput(ns("prag_n0"), "Prag Retry (n0)", 1, min=0),
                    numericInput(ns("prag_t0"), "Prag Timp Bun (t0)", 200, min=1),
                    actionButton(ns("btn_calc"), "Calculeaza", class="btn-primary")
                )
            ),
            column(8,
                h3("Rezultate Probabilitati Conditionate"),
                tableOutput(ns("tabel_rezultate")),
                wellPanel(
                    h5("Explicatii Notatii:"),
                    p("P(A | N <= n0) : Sansa de succes daca am avut putine incercari."),
                    p("P(B | A) : Sansa ca timpul sa fie bun (<= t0) daca am avut succes."),
                    p("E(T | I=1) : Timpul mediu petrecut pentru cererile cu SUCCES."),
                    p("E(T | I=0) : Timpul mediu petrecut pentru cererile ESUATE.")
                )
            )
        )
    )
}

ex6_conditionate_server <- function(id) {
    moduleServer(id, function(input, output, session) {
        
        rezultate <- eventReactive(input$btn_calc, {
            # simulam datele
            df <- simuleaza_evenimente(
                nr_simulari = input$nr_simulari,
                prob_succes = input$p_succes,
                medie_latenta = input$medie_latenta,
                nr_max_retry = input$nr_max_retry
            )
            
            # calculam conditionatele
            calculeaza_conditionate(df, prag_retry_mic = input$prag_n0, prag_timp_bun = input$prag_t0)
        })
        
        output$tabel_rezultate <- renderTable({
            res <- rezultate()
            req(res)
            
            data.frame(
                Metric = c(
                    "P(Succes | Retry <= n0)",
                    "P(Timp <= t0 | Succes)",
                    "Timp Mediu (Succes)",
                    "Timp Mediu (Esec)"
                ),
                Valoare = c(
                    res$Probabilitate_Succes_daca_Retry_Mic,
                    res$Probabilitate_TimpBun_daca_Succes,
                    res$Timp_Mediu_Succes,
                    res$Timp_Mediu_Esec
                )
            )
        })
    })
}
