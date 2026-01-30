# exercitiul 3: ui
# donea fernando - emanuel

ex3_evenimente_UI <- function(id) {
    ns <- NS(id)

    tagList(
        fluidRow(
            column(
                4,
                wellPanel(
                    h4("Parametri simulare"),
                    numericInput(ns("prob_succes"), "Probabilitate succes (p_succes)", value = 0.6, min = 0.01, max = 1, step = 0.05),
                    numericInput(ns("nr_max_retry"), "Numar maxim repetari (retry)", value = 3, min = 0),
                    numericInput(ns("medie_latenta"), "Medie latenta (ms)", value = 50, min = 1),
                    numericInput(ns("nr_simulari"), "Numar simulari", value = 1000, min = 100),
                    hr(),
                    h4("Definitie evenimente"),
                    helpText("B: timp total <= t0"),
                    numericInput(ns("timp_limita"), "Limita timp (t0)", value = 150),
                    helpText("C: nr. retry-uri <= n0"),
                    numericInput(ns("nr_retry_limita"), "Limita retry (n0)", value = 1),
                    actionButton(ns("btn_sim_evenimente"), "Simuleaza evenimente", class = "btn-primary")
                )
            ),
            column(
                8,
                tabsetPanel(
                    tabPanel(
                        "Estimari empirice",
                        br(),
                        h4("Probabilitati estimate"),
                        tableOutput(ns("tabel_probabilitati"))
                    ),
                    tabPanel(
                        "Verificare formule",
                        br(),
                        h4("1. Verificare numerica reuniune (A U D)"),
                        p("Formula: P(A ∪ D) = P(A) + P(D) - P(A ∩ D)"),
                        h5(strong("empiric:")),
                        uiOutput(ns("verif_AD_empiric")),
                        br(),
                        h5(strong("teoretic:")),
                        uiOutput(ns("verif_AD_teoretic")),
                        hr(),
                        h4("2. Verificare numerica intersectie (A ∩ B)"),
                        p("formula: P(A ∩ B) = P(A) + P(B) - P(A ∪ B)"),
                        h5(strong("empiric:")),
                        uiOutput(ns("verif_AB_empiric")),
                        br(),
                        h5(strong("teoretic:")),
                        uiOutput(ns("verif_AB_teoretic"))
                    ),
                    tabPanel(
                        "Explicatii",
                        br(),
                        h4("De ce probabilitatea empirica aproximeaza bine probabilitatea teoretica?"),
                        uiOutput(ns("explicatii_text"))
                    )
                )
            )
        )
    )
}
