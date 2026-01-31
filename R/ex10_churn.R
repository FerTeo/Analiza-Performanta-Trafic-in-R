# exercitiul 10: churn (pierderea utilizatorilor)


library(ggplot2)
library(dplyr)
library(plotly)

# functie pentru simulare churn aleator
simulate_churn_random <- function(N, q, sims) {
    # N = numar pasi (timp/cereri)
    # q = probabilitate churn per pas
    # sims = numar simulari

    if (q == 0) {
        return(rep(NA, sims))
    }

    # generam o matrice de (sims x N) cu valori uniforme
    random_vals <- matrix(runif(sims * N), nrow = sims, ncol = N)

    # verificam unde valoarea < q (eveniment churn)
    churn_matrix <- random_vals < q

    # gasim primul moment de churn pentru fiecare simulare
    # max.col cu ties.method="first" returneaza primul TRUE
    # daca nu exista TRUE, vrem sa stim asta
    # adaugam o coloana de TRUE la final
    churn_matrix <- cbind(churn_matrix, TRUE)
    first_churn <- max.col(churn_matrix, ties.method = "first")

    # cei care au churn index = N+1 inseamna ca nu au churnuit
    churn_times <- first_churn
    churn_times[churn_times > N] <- NA

    return(churn_times)
}

# functie pentru simulare churn conditional (ferestre)
simulate_churn_conditional <- function(N, m, k, p_fail, sims) {
    # N = numar pasi
    # m = dimensiune fereastra
    # k = prag esecuri
    # p_fail = probabilitate esec cerere

    # generam esecuri (1=esec,0=succes)
    failures <- matrix(rbinom(sims * N, 1, p_fail), nrow = sims, ncol = N)

    # functie aplicata pe fiecare rand
    results <- apply(failures, 1, function(row) {
        # rolling sum. sides=1 inseamna ca fereastra este [t-m+1, t]
        rsum <- stats::filter(row, rep(1, m), sides = 1)

        # identificam indicii unde conditia e indeplinita
        idx <- which(rsum >= k)

        if (length(idx) > 0) {
            return(idx[1])
        } else {
            return(NA)
        }
    })

    return(results)
}

ex10_churn_server <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            # reactiva pentru simulare
            simulation_data <- eventReactive(input$btn_sim, {
                req(input$q, input$m, input$k, input$p_fail, input$steps, input$sims)

                N <- input$steps
                sims <- input$sims

                # scenariul A
                times_A <- simulate_churn_random(N, input$q, sims)

                # scenariul B
                times_B <- simulate_churn_conditional(N, input$m, input$k, input$p_fail, sims)

                # calculam cdf (probabilitate cumulata de churn)
                t_seq <- 1:N

                # functie helper pentru calcul proportie
                calc_prob <- function(times, step) {
                    sum(!is.na(times) & times <= step) / sims
                }

                prob_A <- sapply(t_seq, function(t) calc_prob(times_A, t))
                prob_B <- sapply(t_seq, function(t) calc_prob(times_B, t))

                data.frame(
                    Step = rep(t_seq, 2),
                    Probability = c(prob_A, prob_B),
                    Scenario = rep(c("Aleator (q)", "Conditional (m, k)"), each = N)
                )
            })

            output$plot_churn <- renderPlotly({
                req(simulation_data())

                p <- ggplot(simulation_data(), aes(x = Step, y = Probability, color = Scenario)) +
                    geom_line(size = 1) +
                    labs(
                        title = "Evolutia Probabilitatii de Churn (Pierderea Utilizatorului)",
                        x = "Pas (Timp / Cereri)",
                        y = "Probabilitate Cumulata"
                    ) +
                    theme_minimal() +
                    scale_color_manual(values = c("Aleator (q)" = "blue", "Conditional (m, k)" = "red"))

                ggplotly(p)
            })

            output$stats_churn <- renderTable({
                req(simulation_data())

                df <- simulation_data()

                # extragem ultima valoare (la pasul N)
                prob_final_A <- df %>%
                    filter(Scenario == "Aleator (q)", Step == max(Step)) %>%
                    pull(Probability)

                prob_final_B <- df %>%
                    filter(Scenario == "Conditional (m, k)", Step == max(Step)) %>%
                    pull(Probability)

                data.frame(
                    Scenariu = c("Aleator (q)", "Conditional (m, k)"),
                    Probabilitate_Finala = c(
                        paste0(round(prob_final_A * 100, 2), "%"),
                        paste0(round(prob_final_B * 100, 2), "%")
                    )
                )
            })

            output$interpretare <- renderUI({
                req(simulation_data())

                df <- simulation_data()
                prob_final_A <- df %>%
                    filter(Scenario == "Aleator (q)", Step == max(Step)) %>%
                    pull(Probability)

                prob_final_B <- df %>%
                    filter(Scenario == "Conditional (m, k)", Step == max(Step)) %>%
                    pull(Probability)

                diff_text <- if (abs(prob_final_A - prob_final_B) < 0.05) {
                    "Cele doua scenarii au un risc similar."
                } else if (prob_final_A > prob_final_B) {
                    "Scenariul Aleator prezinta un risc mai mare de pierdere a utilizatorilor."
                } else {
                    "Scenariul Conditional (bazat pe erori) prezinta un risc mai mare."
                }

                tagList(
                    h4("Concluzii"),
                    p(paste0("Dupa ", input$steps, " pasi simulati:")),
                    tags$ul(
                        tags$li(paste0("Probabilitatea de pierdere in scenariul Aleator este ", round(prob_final_A, 4))),
                        tags$li(paste0("Probabilitatea de pierdere in scenariul Conditional este ", round(prob_final_B, 4)))
                    ),
                    p(strong("Interpretare:"), diff_text),
                    p("Scenariul aleator depinde doar de q, in timp ce scenariul conditional depinde de calitatea serviciului (probabilitatea de eroare) si toleranta utilizatorului (k din m).")
                )
            })
        }
    )
}
