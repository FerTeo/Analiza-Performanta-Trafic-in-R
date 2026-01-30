library(dplyr)
library(ggplot2)


# simulare economica 
simuleaza_business_case <- function(nr_zile, lambda_mediu, 
                                    prob_succes, medie_latenta, nr_max_retry,
                                    eco_params) {
  
  
  trafic_zilnic <- genereaza_trafic_integrat(nr_zile, lambda_mediu)
  
  profituri <- numeric(nr_zile)
  venituri <- numeric(nr_zile)
  pierderi <- numeric(nr_zile)
  
  # iteram prin zile pentru analiza individuala a clientilor si efectul total asupra activitatii firmei 
  for (i in 1:nr_zile) {
    n_clienti <- trafic_zilnic[i]
    
    if (n_clienti > 0) {
      df_zi <- simuleaza_evenimente(n_clienti, prob_succes, medie_latenta, nr_max_retry)
      
      #definim functia de profit
      #veniturile calculate in urma cererilor cu succes 
      incasari_zi <- sum(df_zi$I == 1) * eco_params$castig
      
      #pierderile Churn (costul de oportunitate), in cazul clientilor care au renuntat exista pierderi 
      #de obicei este mai mare decat profitul 
      cost_churn_zi <- sum(df_zi$I == 0) * eco_params$pierdere
      
      #penalitatile SLA: Succes (I=1), Timp > t_sla pentru o plata de penalizare
      nr_penalitati <- sum(df_zi$I == 1 & df_zi$T > eco_params$t_sla)
      cost_sla_zi <- nr_penalitati * eco_params$penalitate
      
      #totalurile
      venituri[i] <- incasari_zi
      pierderi[i] <- cost_churn_zi + cost_sla_zi
      profituri[i] <- incasari_zi - cost_churn_zi - cost_sla_zi
      
    } else {
      profituri[i] <- 0
      venituri[i] <- 0
      pierderi[i] <- 0
    }
  }
  #istoricul financiar pe an pentru desenarea graficului
  return(data.frame(
    zi = 1:nr_zile,
    venit = venituri,
    pierdere = pierderi,
    profit = profituri
  ))
}

# functia pentru statisticile economice 
calculeaza_statistici_eco <- function(df_rezultate) {
  profit <- df_rezultate$profit
  
  list(
    medie_profit = mean(profit),
    deviatie_profit = sd(profit),
    profit_total = sum(profit),
    zile_cu_pierdere = sum(profit < 0),
    probabilitate_pierdere = mean(profit < 0) * 100,
    profit_min = min(profit),
    profit_max = max(profit)
  )
}


ex11_impact_economic_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # simularea datelor 
    date_eco <- eventReactive(input$btn_calc_eco, {
      req(input$lambda, input$pret)
      
      #preluarea de parametrii economici necesari 
      params <- list(
        castig = input$pret,
        pierdere = input$cost_churn,
        t_sla = input$sla_limit,
        penalitate = input$sla_penalty
      )
      
      #procentul de succes devine o probabilitate
      p_succes <- input$prob_succes / 100
      
      #apelam functia de logica si simulam pentru un an standard si 3 retry-uri standard
      simuleaza_business_case(
        nr_zile = 365,
        lambda_mediu = input$lambda,
        prob_succes = p_succes,
        medie_latenta = input$latenta,
        nr_max_retry = 3, 
        eco_params = params
      )
    })
    
    # statisticile
    stats <- reactive({
      req(date_eco())
      calculeaza_statistici_eco(date_eco())
    })
    
    output$txt_medie <- renderText({
      paste(round(stats()$medie_profit, 1), "RON")
    })
    
    output$txt_risc <- renderText({
      paste(round(stats()$probabilitate_pierdere, 1), "% (Zile pe minus)")
    })
    
    output$txt_total <- renderText({
      total <- stats()$profit_total
      if(abs(total) > 1000000) {
        paste(round(total/1000000, 2), "M RON")
      } else {
        paste(round(total/1000, 1), "k RON")
      }
    })
    
    #Line Plot (evolutia)
    output$plot_evolutie <- renderPlot({
      df <- date_eco()
      #media mobila pentru a vedea trendul mai clar 
      ggplot(df, aes(x = zi, y = profit)) +
        geom_line(color = "gray", alpha=0.6) +
        geom_smooth(method = "loess", color = "blue", se = FALSE) +
        geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
        labs(title = "Evolutia Profitului Zilnic (Simulare 1 an)", y = "Profit (RON)") +
        theme_minimal()
    })
    
    #histograma
    output$plot_hist <- renderPlot({
      df <- date_eco()
      ggplot(df, aes(x = profit)) +
        geom_histogram(fill = "forestgreen", color = "white", bins = 30) +
        geom_vline(xintercept = 0, color = "red", size=1.5) +
        labs(title = "Distributia Profitului (Cat de des castigam vs pierdem)", 
             subtitle = "Linia rosie = Pragul de rentabilitate (0 RON)",
             x = "Profit Zilnic", y = "Nr. Zile") +
        theme_minimal()
    })
    
    #in cazul de compromis se afiseaza un text explicativ 
    output$explicatie_tradeoff <- renderUI({
      s <- stats()
      
      # analiza automata
      mesaj <- if (s$medie_profit > 0) {
        div(style="color:green", icon("check"), "Sistemul este PROFITABIL in medie.")
      } else {
        div(style="color:red", icon("exclamation-triangle"), "ATENTIE: Sistemul pierde bani! Costurile de Churn/SLA sunt prea mari.")
      }
      
      tagList(
        mesaj,
        p(paste("Din 365 de zile,", s$zile_cu_pierdere, "zile au fost incheiate cu pierdere financiara.")),
        p("Compromisul economic arata ca pentru a reduce aceste pierderi, trebuie fie sa cresti calitatea tehnica (Rata Succes), fie sa renegociezi penalitatile (SLA).")
      )
    })
    
  })
}