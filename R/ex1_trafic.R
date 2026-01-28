# Modelarea traficului zilnic (variabile aleatoare discrete)
# Donea Fernando-Emanuel


library(ggplot2)
library(dplyr)#pentru filter, group_by si summarise
library(plotly)#pentru a vizona mai bine histogramele

trafic_simulat_poisson <- function (zile, lambda_val)
{
  #genera un esantion de valori discrete cu rpois
  rpois(zile, lambda=lambda_val)
}

trafic_simulat_binomiala <- function(zile, n_val,p_val)
{
  #modelam traficul cu plafon maxim(n) cu rbinom
  rbinom(zile,size=n_val,prob = p_val)
}


trafic_teoretic_poisson <-function(lambda_val)
{
  #la Poisson
  #media=varianta=lambda
  
  return(list(m=lambda_val,v=lambda_val))
}

trafic_teoretic_binomiala <-function(n_val, p_val)
{
  #la Binomiala:
  #media=n*p
  #varianta=n*p*(1-p)
  
  medie <- n_val*p_val
  varianta<-n_val*p_val*(1-p_val)
  
  return(list(m=medie,v=varianta))

}



ex1_trafic_server <- function (id)
{
  moduleServer(id, 
               function(input, output, session)
               {
                 
                 date_trafic <- eventReactive(input$btn_sim_trafic,
                 {
                   zile_totale <- input$sim_ani*365
                   
                   #k_d
                   K_d <- if(input$distributie_trafic=='Poisson')
                   {
                     trafic_simulat_poisson(zile_totale, input$lambda)
                   }
                   else
                   {
                     trafic_simulat_binomiala(zile_totale, input$n_binom, input$p_binom)
                   }
                   
                   data.frame(
                     zile=1:zile_totale,
                     anul=rep(1:input$sim_ani, each=365)[1:zile_totale],
                     luna=rep(rep(1:12, each=30), length.out = zile_totale),
                     clienti=K_d
                   )
                 })
                 
                 
                 # reactive value pentru a stoca selectia utilizatorului
                 selected_view <- reactiveVal(NULL)
                 
                 # observer pentru a putea da click pe grafic
                 observeEvent(event_data("plotly_click", source = "trafic_lunar"), {
                   click_data <- event_data("plotly_click", source = "trafic_lunar")
                   if (!is.null(click_data)) {
                        selected_view(click_data)
                   }
                  })
                 
                 # resetam view-ul
                 observeEvent(input$btn_reset_view, {
                   selected_view(NULL)
                 })
                 
                 # UI pentru butonul de reset
                 output$ui_reset_button <- renderUI({
                   if (!is.null(selected_view())) {
                     actionButton(session$ns("btn_reset_view"), "Inapoi", icon = icon("arrow-left"))
                   }
                 })

                 #histograma pentru trafic anual
                 output$plot_trafic_anual<- renderPlotly(
                   {
                     req(date_trafic())
                     
                     p <- ggplot(date_trafic(), aes(x = clienti)) + 
                       geom_histogram(fill = "skyblue", color = "black", bins = 30) +
                       facet_wrap(~anul) + 
                       theme_minimal() + 
                       labs(title = "Distributia Traficului pe Ani")
                       
                     ggplotly(p) %>% config(displayModeBar = FALSE)
                   }
                 )
                 
                 
                 #historgrama pentru trafic lunar
                 output$plot_trafic_lunar <-renderPlotly(
                   {
                     req(date_trafic())
                     
                     dt <- date_trafic()
                     
                     if (is.null(selected_view())) {
                       
                       # view de tip grid
                       
                       p <- ggplot(dt, aes(x = clienti, customdata = paste(anul, "-", luna))) + 
                         geom_histogram(fill = "orange", color = "black", bins = 15) +
                         facet_grid(anul ~ luna, scales = "free_y") + 
                         theme_minimal() + 
                         theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                         labs(title = "Distributia Traficului pe Luni", subtitle = "Click pe o histogramt pentru detalii")

                       ggplotly(p, source = "trafic_lunar") %>% 
                         config(displayModeBar = FALSE) %>%
                         event_register("plotly_click")

                     } else {
                       # histograma individuala pentru fiecare luna
                       click_info <- selected_view()
                       
                       
                       if (!is.null(click_info$customdata)) {
                         #selectam informatii din customdata pentru a putea alege histograma unei anumite luni dintr-un anumit an
                           sel_str <- as.character(click_info$customdata)
                           parts <- strsplit(sel_str, " - ")[[1]]
                           
                           if(length(parts) >= 2) {
                               sel_an <- as.integer(parts[1])
                               sel_luna <- as.integer(parts[2])
                               
                               df_filtrat <- dt %>% filter(anul == sel_an, luna == sel_luna)
                               
                               p <- ggplot(df_filtrat, aes(x = clienti)) + 
                                 geom_histogram(fill = "orange", color = "black", bins = 30) +
                                 theme_minimal() + 
                                 labs(title = paste("Distributia Traficului - Anul", sel_an, "Luna", sel_luna))
                               
                               ggplotly(p) %>% config(displayModeBar = FALSE)
                           } else {
                               ggplotly(ggplot(dt, aes(x=clienti)) + geom_histogram()) %>% config(displayModeBar = FALSE) 
                           }
                       } else {
                            ggplotly(ggplot(dt, aes(x=clienti)) + geom_histogram()) %>% config(displayModeBar = FALSE)
                       }

                     }
                   }
                 )
                 
                 
                 
                 #tabel statistici: empiric vs teoretic
                 output$statistici_trafic_anual <- renderTable(
                   {
                     req(date_trafic())
                     
                     teor <- if(input$distributie_trafic=='Poisson')
                     {
                       trafic_teoretic_poisson(input$lambda)
                     }
                     else
                     {
                       trafic_teoretic_binomiala(input$n_binom, input$p_binom)
                     }
                     
                     date_trafic() %>% group_by(anul) %>%
                     summarise(
                       medie_empirica = mean(clienti),
                       medie_teoretica = teor$m,
                       
                       varianta_empirica = var(clienti),
                       varianta_teoretica = teor$v
                     )
                     
                     
                     
                   }
                 )
                 
                 
                 
                 
                 
                 
                 
               })
}
