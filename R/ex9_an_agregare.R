library(dplyr)
library(ggplot2)


genereaza_trafic_integrat <- function(nr_zile, lambda_baza) {
    vec_luni <- rep(rep(1:12, each = 30), length.out = nr_zile)
    vec_anotimpuri <- sapply(vec_luni, get_anotimp)

    # factori de sezonalitate conform logicii ex1
    map_factor <- c("Iarna" = 0.8, "Primavara" = 1.0, "Vara" = 1.5, "Toamna" = 1.1)
    vec_factori <- map_factor[vec_anotimpuri]

    #vector care contine media fiecarei zi conform anotimpului, deci in final anului,
    #in functie de lambda_baza care reprez media generala de clienti  
    lambda_vec <- lambda_baza * vec_factori
  
    
    #genereaza numarul efectiv de clienti per zilele din anotimpuri urmarite de trafic
    trafic_zilnic <- rpois(nr_zile, lambda = lambda_vec)

    return(trafic_zilnic)
}


genereaza_agregat_zilnic_integrat <- function(nr_zile, lambda_mediu,
                                              prob_succes, medie_latenta, nr_max_retry,
                                              tip_analiza = "profit", # "profit" sau "latenta"
                                              params_eco = list()) {
    #generam numarul de clienti pe zile 
    clienti_pe_zile <- genereaza_trafic_integrat(nr_zile, lambda_mediu)

    rezultate_zilnice <- numeric(nr_zile)

    #iteram prin fiecare zi pentru a analiza cum activitatea individuala a unui client 
    #influenteaza activitatea firmei pe acea zi 
    for (zi in 1:nr_zile) {
        nr_clienti_azi <- clienti_pe_zile[zi]
        if (nr_clienti_azi > 0) {
          #simulam comportamentul a nrului de clienti efectiv pe acea zi cu prob de succes X si latenta Y 
            df_zi <- simuleaza_evenimente(
                nr_simulari = nr_clienti_azi,
                prob_succes = prob_succes,
                medie_latenta = medie_latenta,
                nr_max_retry = nr_max_retry
            )
            #comanda pentru UI in Shiny pentru afisare de latenta sau profit 

            if (tip_analiza == "latenta") {
                #suma latentelor calculata pe coloana T, pt a obt nr total de ms consumate de server in acea zi 
                rezultate_zilnice[zi] <- sum(df_zi$T)
            } else {
                # calculam profitul pentru logica economica din spatele ex 11
                # params_eco conține: castig, pierdere, t_sla, penalitate

                # venit (I==1)
                venit <- sum(df_zi$I == 1) * params_eco$castig

                # pierderi Churn  (I==0)
                pierdere <- sum(df_zi$I == 0) * params_eco$pierdere

                # penalitatile SLA (I==1 si T>t_sla)
                slas_incalcate <- sum(df_zi$I == 1 & df_zi$T > params_eco$t_sla)
                amenda <- slas_incalcate * params_eco$penalitate

                rezultate_zilnice[zi] <- venit - pierdere - amenda
            }
        } else {
            rezultate_zilnice[zi] <- 0
        }
    }

    return(data.frame(zi = 1:nr_zile, valoare = rezultate_zilnice))
}


test_aproximare_normala <- function(vals) {
  medie_emp <- mean(vals)
  sd_emp <- sd(vals)
  #desenarea liniei rosie 
  list(
    medie = medie_emp,
    sd = sd_emp
  )
}


ex9_an_agregare_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    #simularea datelor 
    date_simulate <- eventReactive(input$btn_sim_agregat, {
      req(input$nr_zile, input$lambda_mediu)
      
      #lista de parametri economici pentru profit 
      params <- list(
        castig = input$castig_per_succes,
        pierdere = input$pierdere_per_churn,
        t_sla = input$t_sla,
        penalitate = input$penalitate_sla
      )
      
      genereaza_agregat_zilnic_integrat(
        nr_zile = input$nr_zile,
        lambda_mediu = input$lambda_mediu,
        prob_succes = input$prob_succes_ag,
        medie_latenta = input$medie_latenta_ag,
        nr_max_retry = input$nr_max_retry_ag,
        tip_analiza = input$tip_agregat,
        params_eco = params
      )
    })
    
    # gf histo si curba normala 
    output$plot_histograma_agregat <- renderPlot({
      req(date_simulate())
      df <- date_simulate()
      vals <- df$valoare
      
      #media si deviatia standard pentru linia rosie 
      params_norm <- test_aproximare_normala(vals)
      
      titlu_grafic <- if(input$tip_agregat == "profit") "Distributia profitului zilnic" else "Distributia latentei totale"
      unitate <- if(input$tip_agregat == "profit") "RON" else "ms"
      
      ggplot(df, aes(x = valoare)) +
        # histograma(datele reale)
        geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", color = "black", alpha = 0.7) +
        #curba normala (teoria)
        stat_function(fun = dnorm, args = list(mean = params_norm$medie, sd = params_norm$sd), 
                      color = "red", size = 1.5) +
        labs(title = titlu_grafic,
             subtitle = paste("Linia rosie = Aproximarea normala teoretica (Medie:", round(params_norm$medie, 2), ")"),
             x = paste("Valoare (", unitate, ")"), 
             y = "Densitate") +
        theme_minimal()
    })
    
    # qq Plot 
    output$plot_qq <- renderPlot({
      req(date_simulate())
      vals <- date_simulate()$valoare
      
      qqnorm(vals, main = "QQ Plot: Verificare vizuala a normalitatii")
      qqline(vals, col = "red", lwd = 2)
    })
    
    #concluzie
    output$interpretare_aproximare <- renderUI({
      req(date_simulate())
      tagList(
        h4("Concluzie Vizuala:"),
        p("Analizand graficul, observam ca distributia empirica (barele albastre) tinde sa se suprapuna cu curba teoretica Normala (linia rosie)."),
        p("Acest lucru confirma vizual Teorema Limita Centrala: suma multor variabile aleatoare independente (rezultatele clientilor individuali) tinde sa urmeze o distributie Normala cand este agregata pe zi."),
        p(strong("Observatie:"), " Daca profitul mediu (varful clopotului) este negativ, parametrii economici trebuie ajustati (ex: scade costul de churn sau creste pretul).")
      )
    })
    
  })
}
