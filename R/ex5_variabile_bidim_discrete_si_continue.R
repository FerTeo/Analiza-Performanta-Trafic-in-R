# Variabile aleatoare bidimensionale (discrete si continue) (N, T)

# Functie simulare (N, T)
simuleaza_NT <- function(nr_simulari, p_succes, nr_max_retry, latenta_medie, latenta_sd) {
  
  vec_N <- numeric(nr_simulari)
  vec_T <- numeric(nr_simulari)
  
  for(i in 1:nr_simulari) {
    timp_total <- 0
    n_attempts <- 0
    
    total_posibile <- nr_max_retry + 1
    
    for(k in 1:total_posibile) {
      n_attempts <- k
      # se genereaza latenta pt incercarea curenta (normala trunchiata la pozitiv)
      l <- rnorm(1, mean=latenta_medie, sd=latenta_sd)
      if(l < 0.1) l <- 0.1
      timp_total <- timp_total + l
      
      if(runif(1) <= p_succes) {
        break # daca are succes se opreste
      }
      # altfel se reincearca
    }
    
    vec_N[i] <- n_attempts
    vec_T[i] <- timp_total
  }
  
  return(data.frame(N = vec_N, T = vec_T))
}

ex5_corelatie_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    date_nt <- eventReactive(input$btn_sim_nt, {
      simuleaza_NT(input$nr_sim, input$prob_succes, input$max_retry, input$medie_lat, input$sd_lat)
    })
    
    # reprezentare grafica (boxplot N vs T)
    output$plot_nt <- renderPlotly({
      req(date_nt())
      df <- date_nt()
      
      p <- ggplot(df, aes(x=factor(N), y=T, fill=factor(N))) +
        geom_boxplot() +
        labs(title="Relatia dintre Nr. Incercari (N) si Timpul Total (T)", x="Nr. Incercari (N)", y="Timp Total (T) [ms]") +
        theme_minimal() +
        theme(legend.position="none")
      
      ggplotly(p)
    })
    
    # b) covarianta si corelatia
    output$statistici_nt <- renderTable({
      req(date_nt())
      df <- date_nt()
      
      cov_val <- cov(df$N, df$T)
      cor_val <- cor(df$N, df$T)
      
      data.frame(
        Statistica = c("Media N", "Media T", "Varianta N", "Varianta T", "Covarianta cov(N,T)", "Corelatia Pearson rho(N,T)"),
        Valoare = c(mean(df$N), mean(df$T), var(df$N), var(df$T), cov_val, cor_val)
      )
    })
    
    # Interpretare
    output$interpretare_nt <- renderUI({
      req(date_nt())
      df <- date_nt()
      cor_val <- cor(df$N, df$T)
      
      tagList(
        h4("Interpretare Corelatie"),
        p(paste("Coeficientul de corelatie este:", round(cor_val, 4))),
        p("Se observa o corelatie pozitiva puternica. Acest lucru este natural: cu cat sistemul face mai multe retry-uri (N creste), cu atat timpul total de asteptare (T) creste, deoarece T este suma latentelor individuale."),
        p("Covarianta pozitiva indica faptul ca cele doua variabile variaza in aceeasi directie.")
      )
    })
    
  })
}