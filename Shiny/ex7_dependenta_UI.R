source("R/ex7_dependenta.R")
source("R/ex3_evenimente.R") # pentru cazul independent (comparatie)

ex7_dependenta_UI <- function(id) {
    ns <- NS(id)
    tagList(
        fluidRow(
            column(4,
                wellPanel(
                    h4("Comparatie Dependenta"),
                    numericInput(ns("nr_simulari"), "Numar Simulari", 2000, min=100),
                    numericInput(ns("p_succes"), "Probabilitate Succes", 0.5, min=0.01, max=1),
                    numericInput(ns("medie_latenta"), "Latenta Initiala (ms)", 100, min=1),
                    numericInput(ns("nr_max_retry"), "Max Retry", 3, min=0),
                    hr(),
                    h5("Setari Dependenta:"),
                    numericInput(ns("factor_penalizare"), "Factor Penalizare (ex: 1.5)", 1.5, step=0.1),
                    helpText("Dupa fiecare esec, latenta creste de X ori."),
                    actionButton(ns("btn_sim"), "Simuleaza Comparativ", class="btn-primary")
                )
            ),
            column(8,
                tabsetPanel(
                    tabPanel("Grafic Comparativ", 
                        plotOutput(ns("plot_comparativ")),
                        h4("Statistici Sumare"),
                        tableOutput(ns("tabel_stats"))
                    )
                )
            )
        )
    )
}

ex7_dependenta_server <- function(id) {
    moduleServer(id, function(input, output, session) {
        
        date_comp <- eventReactive(input$btn_sim, {
            # simulare independenta
            df_indep <- simuleaza_evenimente(
                nr_simulari = input$nr_simulari,
                prob_succes = input$p_succes,
                medie_latenta = input$medie_latenta,
                nr_max_retry = input$nr_max_retry
            )
            df_indep$Tip = "Independent"
            
            # simulare dependenta
            df_dep <- simuleaza_dependenta(
                nr_simulari = input$nr_simulari,
                prob_succes_per_try = input$p_succes,
                latenta_medie_initiala = input$medie_latenta,
                nr_max_retry = input$nr_max_retry,
                factor_penalizare_latenta = input$factor_penalizare
            )
            df_dep$Tip = "Dependent"
            
            # combinam pentru plot
            rbind(df_indep[, c("T", "Tip")], df_dep[, c("T", "Tip")])
        })
        
        output$plot_comparativ <- renderPlot({
            req(date_comp())
            ggplot(date_comp(), aes(x=T, fill=Tip)) +
                geom_density(alpha=0.5) +
                theme_minimal() +
                labs(title="Distributia Timpului Total (T): Independent vs Dependent", x="Timp (ms)", y="Densitate")
        })
        
        output$tabel_stats <- renderTable({
            req(date_comp())
            date_comp() %>%
                group_by(Tip) %>%
                summarise(
                    Timp_Mediu = mean(T),
                    Timp_Maxim = max(T),
                    Deviatia_Std = sd(T)
                )
        })
    })
}
