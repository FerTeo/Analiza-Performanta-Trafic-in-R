# Variabile aleatoare bidimensionale discrete (N, F)

library(ggplot2)
library(dplyr)
library(reshape2) # pentru melt in heatmap = functie care transforma datele (din tabel/ matrice) intr-o lista necesara pt ggplot2

# Functie simulare (N, F)
simuleaza_NF <- function(nr_simulari, p_succes, nr_max_retry) {
  # N = nr total incercari (1 ... nr_max_retry + 1)
  # F = nr esecuri
  vec_N <- numeric(nr_simulari)
  vec_F <- numeric(nr_simulari)
  
  for(i in 1:nr_simulari) { # desi for nu e ideal
    n_curent <- 0
    f_curent <- 0
    succes <- FALSE
    
    # se executa incercarile de la 1 pana la max_retry + 1)
    # nr_max_retry e nr de reincercari deci total incercari = nr_max_retry + 1
    total_posibile <- nr_max_retry + 1
    
    for(k in 1:total_posibile) {
      n_curent <- k
      # simulare incercare
      if(runif(1) <= p_succes) {
        succes <- TRUE
        f_curent <- k - 1 # nr de esecuri este k - 1 cand se gaseste un succes pe pozitia k 
        break
      } else { # esuare
        f_curent <- k
      }
    }
    
    vec_N[i] <- n_curent
    vec_F[i] <- f_curent
  }
  
  return(data.frame(N = vec_N, F = vec_F))
}

ex4_bidimensional_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # se sim datele
    date_nf <- eventReactive(input$btn_sim_nf, {
      simuleaza_NF(input$nr_sim, input$prob_succes, input$max_retry)
    })
    
    # tabel + heatmap pt distributia comuna
    output$plot_comun <- renderPlotly({
      req(date_nf())
      df <- date_nf()
      
      # tabela de frecventa
      tbl <- table(factor(df$N, levels=1:(input$max_retry+1)), 
                   factor(df$F, levels=0:(input$max_retry+1)))
      
      # ggplot primeste dataframe deci trebuie convertit
      df_heatmap <- as.data.frame(tbl)
      names(df_heatmap) <- c("N", "F", "Frecventa")
      
      # probabilitati empirice
      df_heatmap$Probabilitate <- df_heatmap$Frecventa / sum(df_heatmap$Frecventa)
      
      p <- ggplot(df_heatmap, aes(x=N, y=F, fill=Probabilitate, text=paste("N:", N, "<br>F:", F, "<br>Prob:", round(Probabilitate, 4)))) +
        geom_tile(color="white") +
        scale_fill_gradient(low="white", high="red") +
        labs(title="Distributia Comuna Empirica P(N, F)", x="Nr. Total Incercari (N)", y="Nr. Esecuri (F)") +
        theme_minimal()
      
      ggplotly(p, tooltip="text")
    })
    
    # distributii marginale
    output$plot_marginale <- renderPlot({
      req(date_nf())
      df <- date_nf()
      
      p1 <- ggplot(df, aes(x=factor(N))) + 
        geom_bar(fill="skyblue", color="black", aes(y = (..count..)/sum(..count..))) +
        labs(title="Marginala N (Incercari)", y="Probabilitate", x="N") + theme_minimal()
      
      p2 <- ggplot(df, aes(x=factor(F))) + 
        geom_bar(fill="lightgreen", color="black", aes(y = (..count..)/sum(..count..))) +
        labs(title="Marginala F (Esecuri)", y="Probabilitate", x="F") + theme_minimal()
      
      gridExtra::grid.arrange(p1, p2, ncol=2)
    })
    
    # verificare daca sunt independente
    output$rezultat_test <- renderPrint({
      req(date_nf())
      df <- date_nf()
      
      # Testul Chi-patrat
      # H0: Variabilele sunt independente
      # H1: Variabilele sunt dependente
      test <- chisq.test(table(df$N, df$F))
      print(test)
    })
    
    output$interpretare_test <- renderUI({
      req(date_nf())
      tagList(
        h4("Interpretare Test Independenta"),
        p("Testul Chi-Square verifica ipoteza nula (H0) ca N si F sunt independente."),
        p("Deoarece p-value este extrem de mic (practic 0), respingem H0."),
        p(strong("Concluzie:")),
        p("Variabilele N (nr. incercari) si F (nr. esecuri) sunt putenic dependente. Acest lucru este logic: nu poti avea 3 esecuri daca ai facut doar 1 incercare, iar daca ai facut 3 incercari, numarul de esecuri este fie 2 (succes la ultima), fie 3 (esec total).")
      )
    })
    
  })
}