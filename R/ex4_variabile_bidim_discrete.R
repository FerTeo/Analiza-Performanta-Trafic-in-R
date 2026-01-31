# Variabile aleatoare bidimensionale discrete (N, F)

library(ggplot2)
library(dplyr)
library(reshape2) # pentru melt in heatmap = functie care transforma datele (din tabel/ matrice) intr-o lista necesara pt ggplot2

# functie simulare (N, F)
simuleaza_NF <- function(nr_simulari, p_succes, nr_max_retry) {
  # N = nr total incercari (1 ... nr_max_retry + 1)
  # F = nr esecuri
  vec_N <- numeric(nr_simulari)
  vec_F <- numeric(nr_simulari)

  for (i in 1:nr_simulari) { # desi for nu e ideal
    n_curent <- 0
    f_curent <- 0
    succes <- FALSE

    # se executa incercarile de la 1 pana la max_retry + 1)
    # nr_max_retry e nr de reincercari deci total incercari = nr_max_retry + 1
    total_posibile <- nr_max_retry + 1

    for (k in 1:total_posibile) {
      n_curent <- k
      # simulare incercare
      if (runif(1) <= p_succes) {
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
      tbl <- table(
        factor(df$N, levels = 1:(input$max_retry + 1)),
        factor(df$F, levels = 0:(input$max_retry + 1))
      )

      # ggplot primeste dataframe deci trebuie convertit
      df_heatmap <- as.data.frame(tbl)
      names(df_heatmap) <- c("N", "F", "Frecventa")

      # probabilitati empirice
      df_heatmap$Probabilitate <- df_heatmap$Frecventa / sum(df_heatmap$Frecventa)

      p <- ggplot(df_heatmap, aes(x = N, y = F, fill = Probabilitate, text = paste("N:", N, "<br>F:", F, "<br>Prob:", round(Probabilitate, 4)))) +
        geom_tile(color = "white") +
        scale_fill_gradient(low = "white", high = "red") +
        labs(title = "Distributia Comuna Empirica P(N, F)", x = "Nr. Total Incercari (N)", y = "Nr. Esecuri (F)") +
        theme_minimal()

      ggplotly(p, tooltip = "text")
    })

    # distributii marginale
    output$plot_marginale <- renderPlot({
      req(date_nf())
      df <- date_nf()

      p1 <- ggplot(df, aes(x = factor(N))) +
        geom_bar(fill = "skyblue", color = "black", aes(y = (..count..) / sum(..count..))) +
        labs(title = "Marginala N (Incercari)", y = "Probabilitate", x = "N") +
        theme_minimal()

      p2 <- ggplot(df, aes(x = factor(F))) +
        geom_bar(fill = "lightgreen", color = "black", aes(y = (..count..) / sum(..count..))) +
        labs(title = "Marginala F (Esecuri)", y = "Probabilitate", x = "F") +
        theme_minimal()

      gridExtra::grid.arrange(p1, p2, ncol = 2)
    })

    # verificare daca sunt independente
    output$rezultat_test <- renderPrint({
      req(date_nf())
      df <- date_nf()

      # Verificare Empirica a Independentei
      # P(N, F) vs P(N) * P(F)

      # probabilitatile marginale empirice
      margin_n <- prop.table(table(factor(df$N, levels = 1:(input$max_retry + 1))))
      margin_f <- prop.table(table(factor(df$F, levels = 0:(input$max_retry + 1))))

      # probabilitatea comuna
      comuna <- prop.table(table(
        factor(df$N, levels = 1:(input$max_retry + 1)),
        factor(df$F, levels = 0:(input$max_retry + 1))
      ))
      teoretic_indep <- outer(margin_n, margin_f, "*")

      # diferenta maxima
      diff_matrix <- abs(comuna - teoretic_indep)
      max_diff <- max(diff_matrix)

      cat("Se compara P(N,F) observat cu P(N)*P(F) teoretic.\n\n")
      cat("Diferenta Maxima intre P(N,F) si P(N)*P(F) este ", round(max_diff, 5), "\n")

      if (max_diff > 0.01) {
        cat("Fiind o diferenta mai mare decat 0.01 aceasta nu este neglijabila, deci variabilele N si F sunt dependente")
      } else {
        cat("Diferenta este prea mica si, deci, neglijabila.\n")
        cat("Variabilele (din testul empiric) par independente.\n")
      }
    })

    output$interpretare_test <- renderUI({
      req(date_nf())
      tagList(
        h4("Interpretare Rezultat"),
        p("Se verifica definitia independentei::"),
        p(code("P(N=n, F=f) = P(N=n) * P(F=f)")),
        p("Daca aceasta egalitate are loc pentru toate perechile, variabilele sunt dependente."),
        p("Totusi, faptul ca N si F sunt dependente este clar din faptul ca numarul de esecuri F este intotdeauna mai mic decat N, deci cunoasterea lui N ne da informatii despre F.")
      )
    })
  })
}
