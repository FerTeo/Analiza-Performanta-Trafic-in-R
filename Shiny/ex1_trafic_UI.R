# Donea Fernando - Emanuel

ex1_trafic_UI <- function (id)
{
  ns <- NS(id);
  library(plotly) #pentru a putea viziona histogramele
  
  tagList
  (
    sidebarLayout
    (
      sidebarPanel
      (
        
        h4("Parametrii Trafic"),
        
        #algerea intre Poisson si Binomiala
        selectInput
        (
          ns("distributie_trafic"),"Distributie Trafic (K_d)",
          choices=c("Poisson","Binomiala")
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
      
      
      
      mainPanel
      (
        tabPanel("Histograme",
                 plotlyOutput(ns("plot_trafic_anual")),
                 uiOutput(ns("ui_reset_button")),
                 plotlyOutput(ns("plot_trafic_lunar"))
                 ),
        
        tabPanel("Statistici si Analiza",
                 tableOutput(ns("statistici_trafic_anual")),
                 hr(),
                 h3("Interpretare Rezultate"),
                 p(strong("1. Comparatie Empiric vs Teoretic:")),
                 p("Se observa ca pe masura ce dimensiunea esantionului creste (mai multi ani), media si varianta empirica converg catre valorile teoretice"),
                 
                 p(strong("2. Diferente intre Modele (Trafic Redus vs Plafonat):")),
                 p("• ", strong("Modelul Poisson"), " este adecvat pentru trafic redus, unde sosirile sunt rare si independente. Varianta este egala cu media."),
                 p("• ", strong("Modelul Binomial"), " este adecvat pentru trafic plafonat (ex. capacitate finita), unde numarul de clienti nu poate depasi o valoare n. Varianta este mai mica decat media (sub-dispersie), ceea ce indica o variabilitate mai redusa datorita plafonarii."),
                 br(),
                 br()
                 )
                 
      )
        
      
        
      )
    )
  
  
}