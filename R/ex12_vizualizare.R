#Vizualizare Statistica (T si Profit)

library(ggplot2)
library(dplyr)

# functie de simulare pt T si Profit
simuleaza_profit <- function(nr_simulari, p_succes, max_retry, cost_time, reward_success, cost_retry, medie_latenta, sd_latenta) {
  
  vec_T <- numeric(nr_simulari)
  vec_Profit <- numeric(nr_simulari)
  vec_Outcome <- character(nr_simulari) # succes sau esec
  
  for(i in 1:nr_simulari) {
    timp_total <- 0
    n_attempts <- 0
    succes <- FALSE
    
    total_posibile <- max_retry + 1
    
    for(k in 1:total_posibile) {
      n_attempts <- k
      
      # regenerare latenta
      l <- rnorm(1, mean=medie_latenta, sd=sd_latenta)
      if(l < 0.1) l <- 0.1
      timp_total <- timp_total + l
      
      if(runif(1) <= p_succes) {
        succes <- TRUE
        break
      }
    }
    
    # calcul Profit
    # profit = (in caz de succes) - (cost_timp * T) - (cost_retry * N)
    val_reward <- if(succes) reward_success else 0
    profit <- val_reward - (cost_time * timp_total) - (cost_retry * n_attempts)
    
    vec_T[i] <- timp_total
    vec_Profit[i] <- profit
    vec_Outcome[i] <- if(succes) "succes" else "esec"
  }
  
  return(data.frame(
    T = vec_T, 
    Profit = vec_Profit, 
    Outcome = factor(vec_Outcome, levels = c("succes", "esec"))
  ))
}

ex12_vizualizare_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # reactive pt date simulate
    date_sim <- eventReactive(input$btn_sim_ex12, {
        simuleaza_profit(
            nr_simulari = input$nr_sim_12,
            p_succes = input$prob_succes_12,
            max_retry = input$max_retry_12,
            cost_time = input$cost_time,
            reward_success = input$reward_success,
            cost_retry = input$cost_retry,
            medie_latenta = input$medie_lat_12,
            sd_latenta = input$sd_lat_12
        )
    })
    
    # histograme (T si Profit)
    output$plot_histograme <- renderPlotly({
        req(date_sim())
        df <- date_sim()
        
        # histograma T
        p1 <- ggplot(df, aes(x = T)) +
            geom_histogram(fill = "skyblue", color = "black", bins = 30) +
            labs(title = "Distributia Timpului de Servire (T)", x = "Timp (ms)", y = "Frecventa") +
            theme_minimal()
        
        # histograma profit
        p2 <- ggplot(df, aes(x = Profit)) +
            geom_histogram(fill = "lightgreen", color = "black", bins = 30) +
            labs(title = "Distributia Profitului", x = "Profit (unitati monetare)", y = "Frecventa") +
            theme_minimal()
            
        # se apeleaza si subplot din plotly (alipeste/ impreuneaza graficele)
        subplot(ggplotly(p1), ggplotly(p2), nrows = 2, titleX = TRUE, titleY = TRUE)
    })
    
    # boxploturi T conditionate
    output$plot_boxplot <- renderPlotly({
        req(date_sim())
        df <- date_sim()
        
        p <- ggplot(df, aes(x = Outcome, y = T, fill = Outcome)) +
            geom_boxplot() +
            scale_fill_manual(values = c("succes" = "green", "esec" = "red")) +
            labs(title = "Boxplot Timp (T) conditionat de Rezultat", x = "Rezultat", y = "Timp (ms)") +
            theme_minimal()
            
        ggplotly(p)
    })
    
    # statistici si interpretare (mediana, IQR, outliers)
    output$statistici_detaliate <- renderTable({
        req(date_sim())
        df <- date_sim()
        
        calc_stats <- function(x) {
            q1 <- quantile(x, 0.25)
            q3 <- quantile(x, 0.75)
            iqr_val <- q3 - q1
            lim_inf <- q1 - 1.5 * iqr_val
            lim_sup <- q3 + 1.5 * iqr_val
            outliers <- sum(x < lim_inf | x > lim_sup)
            
            c(Mediana = median(x), 
              IQR = iqr_val, 
              Min = min(x), 
              Max = max(x), 
              Nr_Outliers = outliers,
              Procent_Outliers = (outliers / length(x)) * 100)
        }
        
        stats_t <- calc_stats(df$T)
        stats_profit <- calc_stats(df$Profit)
        
        res <- rbind(stats_t, stats_profit)
        row.names(res) <- c("Timp (T)", "Profit")
        as.data.frame(res)
    }, rownames = TRUE)
    
    output$interpretare_ex12 <- renderUI({
        req(date_sim())
        df <- date_sim()
        
        mediana_t <- median(df$T)
        iqr_t <- IQR(df$T)
        
        tagList(
            h4("Interpretare Statistici"),
            p(strong("Mediana:"), sprintf("Valoarea mediana a timpului este %.2f ms. Aceasta indica centrul distributiei si este mai robusta la valori extreme decat media.", mediana_t)),
            p(strong("IQR (Interquartile Range):"), sprintf("IQR pentru timp este %.2f ms. Acesta masoara dispersia datelor in intervalul central (50%% din date). Un IQR mic indica o consistenta ridicata a timpilor de raspuns.", iqr_t)),
            p(strong("Outlieri:"), "Valorile care depasesc 1.5 IQR fata de quartile sunt considerate outlieri. Prezenta outlierilor la timp (valori foarte mari) sugereaza cazuri rare de latenta extrema sau un numar mare de retry-uri esuate.")
        )
    })
    
  })
}
