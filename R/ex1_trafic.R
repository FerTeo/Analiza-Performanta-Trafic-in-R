# Modelarea traficului zilnic (variabile aleatoare discrete)
# Donea Fernando-Emanuel


library(ggplot2)
library(dplyr) # pentru filter, group_by si summarise
library(plotly) # pentru a vizona mai bine histogramele

trafic_simulat_poisson <- function(zile, lambda_val) {
  # genera un esantion de valori discrete cu rpois
  rpois(zile, lambda = lambda_val)
}

trafic_simulat_binomiala <- function(zile, n_val, p_val) {
  # modelam traficul cu plafon maxim(n) cu rbinom
  rbinom(zile, size = n_val, prob = p_val)
}


trafic_teoretic_poisson <- function(lambda_val) {
  # la Poisson
  # media=varianta=lambda

  return(list(m = lambda_val, v = lambda_val))
}

trafic_teoretic_binomiala <- function(n_val, p_val) {
  # la Binomiala:
  # media=n*p
  # varianta=n*p*(1-p)

  medie <- n_val * p_val
  varianta <- n_val * p_val * (1 - p_val)

  return(list(m = medie, v = varianta))
}


# helper pentru anotimpuri
get_anotimp <- function(m) {
  if (m %in% c(12, 1, 2)) {
    return("Iarna")
  }
  if (m %in% c(3, 4, 5)) {
    return("Primavara")
  }
  if (m %in% c(6, 7, 8)) {
    return("Vara")
  }
  return("Toamna")
}


ex1_trafic_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      date_trafic <- eventReactive(input$btn_sim_trafic, {
        zile_totale <- input$sim_ani * 365

        # generam structura temporala intai
        vec_luni <- rep(rep(1:12, each = 30), length.out = zile_totale)
        vec_anotimpuri <- sapply(vec_luni, get_anotimp)

        # factori de sezonalitate
        # Iarna: 0.8, Primavara: 1.0, Vara: 1.5, Toamna: 1.1
        map_factor <- c("Iarna" = 0.8, "Primavara" = 1.0, "Vara" = 1.5, "Toamna" = 1.1)
        vec_factori <- map_factor[vec_anotimpuri]

        # generare K_d cu parametri ajustati
        K_d <- if (input$distributie_trafic == "Poisson") {
          # lambda variaza in functie de zi
          lambda_vec <- input$lambda * vec_factori
          # rpois accepta vector pentru lambda
          rpois(zile_totale, lambda = lambda_vec)
        } else {
          # N (capacitatea maxima) variaza in functie de zi (e.g. mai multi potentiali clienti vara)
          n_vec <- round(input$n_binom * vec_factori)
          rbinom(zile_totale, size = n_vec, prob = input$p_binom)
        }

        data.frame(
          zile = 1:zile_totale,
          anul = rep(1:input$sim_ani, each = 365)[1:zile_totale],
          luna = vec_luni,
          clienti = K_d
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

      # histograma pentru trafic anual
      output$plot_trafic_anual <- renderPlotly({
        req(date_trafic())

        p <- ggplot(date_trafic(), aes(x = clienti, text = paste("Clienti:", ..x.., "<br>Zile:", ..count..))) +
          geom_histogram(fill = "skyblue", color = "black", bins = 30) +
          facet_wrap(~anul) +
          theme_minimal() +
          labs(title = "Distributia Traficului pe Ani", y = "Zile")

        ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
      })


      # historgrama pentru trafic lunar
      output$plot_trafic_lunar <- renderPlotly({
        req(date_trafic())

        dt <- date_trafic()

        # adaugare etichete luni
        luni_nume <- c("IAN", "FEB", "MAR", "APR", "MAI", "IUN", "IUL", "AUG", "SEP", "OCT", "NOI", "DEC")
        dt$luna_nume <- factor(dt$luna, levels = 1:12, labels = luni_nume)

        # adaugare anotimpuri (functie definita mai sus, refolosim sau apelam din nou)
        # get_anotimp deja exista in scope
        dt$anotimp <- sapply(dt$luna, get_anotimp)
        # legenda anotimpuri
        dt$anotimp <- factor(dt$anotimp, levels = c("Iarna", "Primavara", "Vara", "Toamna"))

        if (is.null(selected_view())) {
          # view de tip grid

          p <- ggplot(dt, aes(
            x = clienti, fill = anotimp, customdata = paste(anul, "-", luna),
            text = paste("Clienti:", ..x.., "<br>Zile:", ..count..)
          )) +
            geom_histogram(color = NA, bins = 15) + # Scoatem conturul negru pentru vizibilitate
            facet_grid(anul ~ luna_nume, scales = "free_y") +
            scale_fill_manual(values = c("Iarna" = "skyblue", "Primavara" = "lightgreen", "Vara" = "orange", "Toamna" = "gold")) +
            theme_minimal() +
            theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
            labs(title = "Distributia Traficului pe Luni", subtitle = "Click pe o histograma pentru detalii", y = "Zile")

          ggplotly(p, source = "trafic_lunar", tooltip = "text") %>%
            config(displayModeBar = FALSE) %>%
            event_register("plotly_click")
        } else {
          # histograma individuala pentru fiecare luna
          click_info <- selected_view()


          if (!is.null(click_info$customdata)) {
            # selectam informatii din customdata pentru a putea alege histograma unei anumite luni dintr-un anumit an
            sel_str <- as.character(click_info$customdata)
            parts <- strsplit(sel_str, " - ")[[1]]

            if (length(parts) >= 2) {
              sel_an <- as.integer(parts[1])
              sel_luna <- as.integer(parts[2])

              df_filtrat <- dt %>% filter(anul == sel_an, luna == sel_luna)

              # calculam anotimpul pentru titlu sau folosim direct din df_filtrat
              p <- ggplot(df_filtrat, aes(x = clienti, fill = anotimp, text = paste("Clienti:", ..x.., "<br>Zile:", ..count..))) +
                geom_histogram(color = "black", bins = 30) +
                scale_fill_manual(values = c("Iarna" = "skyblue", "Primavara" = "lightgreen", "Vara" = "orange", "Toamna" = "gold")) +
                theme_minimal() +
                labs(title = paste("Distributia Traficului - Anul", sel_an, "Luna", sel_luna), y = "Zile")

              ggplotly(p, tooltip = "text") %>% config(displayModeBar = FALSE)
            } else {
              ggplotly(ggplot(dt, aes(x = clienti)) +
                geom_histogram()) %>% config(displayModeBar = FALSE)
            }
          } else {
            ggplotly(ggplot(dt, aes(x = clienti)) +
              geom_histogram()) %>% config(displayModeBar = FALSE)
          }
        }
      })


      # tabel statistici: empiric vs teoretic
      output$statistici_trafic_anual <- renderTable({
        req(date_trafic())

        teor <- if (input$distributie_trafic == "Poisson") {
          trafic_teoretic_poisson(input$lambda)
        } else {
          trafic_teoretic_binomiala(input$n_binom, input$p_binom)
        }

        date_trafic() %>%
          group_by(anul) %>%
          summarise(
            medie_empirica = mean(clienti),
            medie_teoretica = teor$m,
            varianta_empirica = var(clienti),
            varianta_teoretica = teor$v
          )
      })

      # interpretare dinamica
      output$interpretare_comparativa <- renderUI({
        req(date_trafic())
        dt <- date_trafic()

        # adaugam coloana anotimp daca nu exista
        dt$anotimp <- sapply(dt$luna, get_anotimp)

        # statistici sezoniere (vara vs iarna - medie globala per anotimp)
        stats_sezon <- dt %>%
          group_by(anotimp) %>%
          summarise(medie = mean(clienti))
        medie_vara <- stats_sezon %>%
          filter(anotimp == "Vara") %>%
          pull(medie)
        medie_iarna <- stats_sezon %>%
          filter(anotimp == "Iarna") %>%
          pull(medie)

        # statistici anuale (media pe fiecare an)
        stats_anuale <- dt %>%
          group_by(anul) %>%
          summarise(medie = mean(clienti))
        medii_ani <- paste(round(stats_anuale$medie, 1), collapse = ", ")

        tagList(
          p(
            strong("• Variatia Lunara (Sezonalitate):"),
            sprintf(" Histogramele lunare reflecta clar sezonalitatea. Se observa o medie de trafic mult mai ridicata vara (%.1f clienti/zi) fata de iarna (%.1f clienti/zi), confirmand factorii de multiplicare.", medie_vara, medie_iarna)
          ),
          p(
            strong("• Stabilitatea Anuala:"),
            sprintf(" Histogramele anuale arata stabilitate. Mediile anuale sunt foarte apropiate (%s), demonstrand ca distributia globala se mentine constanta pe termen lung.", medii_ani)
          )
        )
      })
    }
  )
}
