# exercitiul 10: ui
# Donea Fernando-Emanuel

ex10_churn_UI <- function(id) {
    ns <- NS(id)

    tagList(
        sidebarLayout(
            sidebarPanel(
                h4("Parametri Churn"),
                numericInput(ns("q"), "Probabilitate Churn Aleator (q)", value = 0.01, min = 0, max = 1, step = 0.001),
                p(helpText("Probabilitatea ca un utilizator sa plece la fiecare pas, independent de erori.")),
                hr(),
                h4("Parametri Conditional"),
                numericInput(ns("m"), "Dimensiune Fereastra (m)", value = 5, min = 1),
                numericInput(ns("k"), "Prag Esecuri (k)", value = 3, min = 1),
                p(helpText("Daca in ultimele m cereri exista >= k esecuri, utilizatorul pleaca.")),
                numericInput(ns("p_fail"), "Probabilitate Esec Cerere", value = 0.1, min = 0, max = 1, step = 0.01),
                p(helpText("Probabilitatea ca o cerere sa esueze (folosita pentru generarea erorilor).")),
                hr(),
                h4("Simulare"),
                numericInput(ns("steps"), "Numar Pasi (N)", value = 100, min = 10),
                numericInput(ns("sims"), "Numar Simulari", value = 1000, min = 100),
                actionButton(ns("btn_sim"), "Simuleaza", class = "btn-primary")
            ),
            mainPanel(
                tabsetPanel(
                    tabPanel(
                        "Grafic si Statistici",
                        plotlyOutput(ns("plot_churn")),
                        br(),
                        h4("Probabilitati Finale (dupa N pasi)"),
                        tableOutput(ns("stats_churn"))
                    ),
                    tabPanel(
                        "Interpretare",
                        uiOutput(ns("interpretare"))
                    )
                )
            )
        )
    )
}
