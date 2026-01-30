# exercitiul 3: cereri, retry-uri si evenimente
# logica de backend pentru simulare si calcul probabilitati

# functie care calculeaza valorile teoretice
calc_teoretic <- function(p_succes, medie_latenta, nr_max_retry, t0, n0) {
    # aici p este p_succes
    p <- p_succes
    q <- 1 - p
    k_max <- nr_max_retry

    # eveniment A: succes eventual
    prob_A <- 1 - q^(k_max + 1)

    # eveniment D: cel putin un esec
    prob_D <- q

    # eveniment C: nr retry-uri <= n0
    prob_C <- 0
    limita_ret <- min(n0, k_max)
    if (limita_ret >= 0) {
        for (k in 0:limita_ret) {
            if (k < k_max) {
                prob_C <- prob_C + (q^k * p)
            } else {
                prob_C <- prob_C + q^k_max
            }
        }
    }

    lambda <- 1 / medie_latenta

    # intersectia dintre A si B (succes si timp bun)
    # se calculeaza prin sumarea probabilitatilor de succes la fiecare tentativa i, conditionat de timp
    prob_A_si_B <- 0
    for (i in 1:(k_max + 1)) {
        prob_scenariu_succes <- q^(i - 1) * p
        prob_A_si_B <- prob_A_si_B + prob_scenariu_succes * pgamma(t0, shape = i, rate = lambda)
    }

    # eveniment B: timp total <= t0
    # B se intampla daca (A si B) SAU (Nesuccess si timp <= t0)
    # componenta (A si B) este deja calculata
    prob_esec_total <- q^(k_max + 1)
    prob_B <- prob_A_si_B + prob_esec_total * pgamma(t0, shape = k_max + 1, rate = lambda)

    # intersectia dintre A si D (succes dar cu esecuri initiale)
    prob_A_si_D <- 0
    for (k in 1:k_max) {
        prob_A_si_D <- prob_A_si_D + q^k * p
    }

    # reuniunea dintre A si D
    prob_A_sau_D <- prob_A + prob_D - prob_A_si_D

    # reuniunea dintre A si B
    prob_A_sau_B <- prob_A + prob_B - prob_A_si_B


    return(list(
        pA = prob_A,
        pB = prob_B,
        pC = prob_C,
        pD = prob_D,
        pA_si_B = prob_A_si_B,
        pA_sau_B = prob_A_sau_B,
        pA_si_D = prob_A_si_D,
        pA_sau_D = prob_A_sau_D
    ))
}


simuleaza_evenimente <- function(nr_simulari, prob_succes, medie_latenta, nr_max_retry) {
    # initializam vectori pentru rezultate
    vec_I <- numeric(nr_simulari)
    vec_T <- numeric(nr_simulari)
    vec_N <- numeric(nr_simulari)

    for (i in 1:nr_simulari) {
        succes_curent <- FALSE
        timp_total <- 0
        nr_incercari_efectuate <- 0

        for (retry in 0:nr_max_retry) {
            nr_incercari_efectuate <- retry
            latenta_curenta <- rexp(1, rate = 1 / medie_latenta)
            timp_total <- timp_total + latenta_curenta

            if (runif(1) <= prob_succes) {
                succes_curent <- TRUE
                break
            }
        }

        vec_I[i] <- as.integer(succes_curent)
        vec_T[i] <- timp_total
        vec_N[i] <- nr_incercari_efectuate
    }

    return(data.frame(I = vec_I, T = vec_T, N = vec_N))
}

calc_probabilitati_empirice <- function(df, t0, n0, teoretic = NULL) {
    is_A <- df$I == 1
    is_B <- df$T <= t0
    is_C <- df$N <= n0
    is_D <- df$N >= 1

    P_A <- mean(is_A)
    P_B <- mean(is_B)
    P_C <- mean(is_C)
    P_D <- mean(is_D)

    P_A_si_B <- mean(is_A & is_B)
    P_A_sau_B <- mean(is_A | is_B)

    P_A_sau_D <- mean(is_A | is_D)
    P_A_si_D <- mean(is_A & is_D)

    list(
        P_A = P_A,
        P_B = P_B,
        P_C = P_C,
        P_D = P_D,
        P_A_si_B = P_A_si_B,
        P_A_sau_B = P_A_sau_B,
        P_A_sau_D = P_A_sau_D,
        P_A_si_D = P_A_si_D,
        teoretic_val = teoretic
    )
}

ex3_evenimente_server <- function(id) {
    moduleServer(id, function(input, output, session) {
        # reactive pentru date simulate
        date_sim <- eventReactive(input$btn_sim_evenimente, {
            req(input$nr_simulari, input$prob_succes, input$medie_latenta)

            simuleaza_evenimente(
                nr_simulari = input$nr_simulari,
                prob_succes = input$prob_succes,
                medie_latenta = input$medie_latenta,
                nr_max_retry = input$nr_max_retry
            )
        })

        # calcul rezultate
        rezultate_calc <- reactive({
            req(date_sim())

            # calculam si teoretic
            teoretic <- calc_teoretic(
                p_succes = input$prob_succes,
                medie_latenta = input$medie_latenta,
                nr_max_retry = input$nr_max_retry,
                t0 = input$timp_limita,
                n0 = input$nr_retry_limita
            )

            calc_probabilitati_empirice(
                date_sim(),
                t0 = input$timp_limita,
                n0 = input$nr_retry_limita,
                teoretic = teoretic
            )
        })

        # output tabele
        output$tabel_probabilitati <- renderTable({
            res <- rezultate_calc()
            teor <- res$teoretic_val

            data.frame(
                eveniment = c(
                    "P(A) - succes",
                    "P(B) - SLA respectat",
                    "P(C) - retry redus",
                    "P(D) - cel putin un esec",
                    "P(A ∩ B) - succes rapid",
                    "P(A U D) - orice rezultat valid"
                ),
                empiric = c(res$P_A, res$P_B, res$P_C, res$P_D, res$P_A_si_B, res$P_A_sau_D),
                teoretic = c(teor$pA, teor$pB, teor$pC, teor$pD, teor$pA_si_B, teor$pA_sau_D),
                eroare = c(
                    abs(res$P_A - teor$pA),
                    abs(res$P_B - teor$pB),
                    abs(res$P_C - teor$pC),
                    abs(res$P_D - teor$pD),
                    abs(res$P_A_si_B - teor$pA_si_B),
                    abs(res$P_A_sau_D - teor$pA_sau_D)
                )
            )
        })

        # helper pentru formatare verificare
        render_verificare <- function(val1, val2, val_subtract, val_result) {
            # val1 + val2 - val_subtract = val_result
            # ex: P(A) + P(D) - P(A inter D) = P(A reun D)

            calc_computed <- val1 + val2 - val_subtract

            tagList(
                div(
                    style = "margin-left: 20px;",
                    p(paste("= ", sprintf("%.4f", val1), " + ", sprintf("%.4f", val2), " - ", sprintf("%.4f", val_subtract))),
                    p(paste("= ", sprintf("%.4f", val_result)))
                )
            )
        }

        # Verificare A U D Empiric
        output$verif_AD_empiric <- renderUI({
            res <- rezultate_calc()
            # P(A U D) = P(A) + P(D) - P(A inter D)
            render_verificare(res$P_A, res$P_D, res$P_A_si_D, res$P_A_sau_D)
        })

        # Verificare A U D Teoretic
        output$verif_AD_teoretic <- renderUI({
            res <- rezultate_calc()
            teor <- res$teoretic_val
            render_verificare(teor$pA, teor$pD, teor$pA_si_D, teor$pA_sau_D)
        })

        # Verificare A inter B Empiric
        output$verif_AB_empiric <- renderUI({
            res <- rezultate_calc()
            # P(A inter B) = P(A) + P(B) - P(A reun B)
            render_verificare(res$P_A, res$P_B, res$P_A_sau_B, res$P_A_si_B)
        })

        # Verificare A inter B Teoretic
        output$verif_AB_teoretic <- renderUI({
            res <- rezultate_calc()
            teor <- res$teoretic_val
            render_verificare(teor$pA, teor$pB, teor$pA_sau_B, teor$pA_si_B)
        })

        output$explicatii_text <- renderUI({
            tagList(
                p("Conform legii numerelor mari (bernoulli), frecventa relativa a aparitiei unui eveniment intr-un numar mare de incercari independente converge catre probabilitatea teoretica."),
                p("De aceea, probabilitatea empirica (calculata pe baza simularii) aproximeaza bine probabilitatea teoretica numerica."),
            )
        })
    })
}
