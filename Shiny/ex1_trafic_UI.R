# Donea Fernando - Emanuel

ex1_trafic_UI <- function(id) {
  ns <- NS(id)
  library(plotly) # pentru a putea viziona histogramele

  tagList(
    sidebarLayout(
      sidebarPanel(
        h4("Parametrii Trafic"),

        # algerea intre Poisson si Binomiala
        selectInput(
          ns("distributie_trafic"), "Distributie Trafic (K_d)",
          choices = c("Poisson", "Binomiala")
        ),
        conditionalPanel(
          condition = paste0("input['", ns("distributie_trafic"), "'] == 'Poisson'"),
          numericInput(ns("lambda"), "Rata medie (lambda) - clienti/zi", value = 100, min = 1)
        ),
        conditionalPanel(
          condition = paste0("input['", ns("distributie_trafic"), "'] == 'Binomiala'"),
          numericInput(ns("n_binom"), "Nr. maxim clienti (n)", value = 200, min = 1),
          sliderInput(ns("p_binom"), "Probabilitate succes (p)", 0, 1, 0.5)
        ),
        numericInput(ns("sim_ani"), "Ani simulare", value = 3, min = 1),
        actionButton(ns("btn_sim_trafic"), "Simuleaza Trafic", class = "btn-primary")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Histograme",
            br(),
            h4("Histograme Trafic"),
            plotlyOutput(ns("plot_trafic_anual")),
            hr(),
            uiOutput(ns("ui_reset_button")),
            plotlyOutput(ns("plot_trafic_lunar")),
            br(),
            hr(),
            h4("Interpretare Comparativa"),
            uiOutput(ns("interpretare_comparativa"))
          ),
          tabPanel(
            "Estimari",
            br(),
            h4("Estimare medie si varianta (empiric vs teoretic)"),
            tableOutput(ns("statistici_trafic_anual"))
          ),
          tabPanel(
            "Explicatii",
            br(),
            h4("Interpretare rezultate si comparatie modele"),
            p(strong("1. Comparatie empiric vs teoretic:")),
            p("Se observa ca pe masura ce dimensiunea esantionului creste (mai multi ani), media si varianta empirica converg catre valorile teoretice"),
            p(strong("2. Diferente intre modele (Trafic redus vs plafonat):")),
            p("• ", strong("Modelul Poisson"), " este adecvat pentru trafic redus, unde sosirile sunt rare si independente. Varianta este egala cu media."),
            p("• ", strong("Modelul Binomial"), " este adecvat pentru trafic plafonat (ex. capacitate finita), unde numarul de clienti nu poate depasi o valoare n. Varianta este mai mica decat media (sub-dispersie), ceea ce indica o variabilitate mai redusa datorita plafonarii.")
          )
        )
      )
    )
  )
}
