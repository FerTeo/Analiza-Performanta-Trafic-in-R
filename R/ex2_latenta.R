# Modelarea timpilor de raspuns (va continue)

# generare date pt latenta
simuleaza_latenta <- function(n, tip, param1, param2) {
  if (tip == "Gamma") {
    # param1 = shape (alfa), param2 = rate (beta)
    return(rgamma(n, shape = param1, rate = param2)) #genereaza 
  } else {
    # normala (trunchiata la 0 pentru a fi realista)
    val <- rnorm(n, mean = param1, sd = param2)
    return(pmax(0.1, val)) # timpul nu poate fi 0 sau negativ
  }
}

# calcul statistici teoretice
statistici_teoretice_latenta <- function(tip, p1, p2) {
  if (tip == "Gamma") {
    medie <- p1 / p2
    varianta <- p1 / (p2^2)
    # modul pt Gamma (daca shape > 1)
    modul <- ifelse(p1 > 1, (p1 - 1) / p2, 0)
    mediana <- qgamma(0.5, shape = p1, rate = p2)
  } else {
    medie <- p1
    varianta <- p2^2
    modul <- p1
    mediana <- p1
  }
  return(list(m = medie, v = varianta, mod = modul, med = mediana))
}

# pt a calcula modulul empiric se ia punctul in care densit de probabilit este cea mai mare
calculeaza_mod_empiric <- function(x) {
  d <- density(x)
  return(d$x[which.max(d$y)])
}

# functie care genereaza inputurile pt distributia aleasa
render_parametri_ui <- function(id, input) {
  ns <- NS(id)
  if (input$dist_tip == "Gamma") {
    tagList(
      numericInput(ns("p1"), "Shape (Alpha):", value = 2, min = 0.1),
      numericInput(ns("p2"), "Rate (Beta):", value = 0.5, min = 0.1),
      helpText("Media teoretica: Alpha / Beta")
    )
  } else {
    tagList(
      numericInput(ns("p1"), "Media (Mu):", value = 100),
      numericInput(ns("p2"), "Deviatia Standard (Sigma):", value = 20, min = 1),
      helpText("Simuleaza un timp de raspuns stabil.")
    )
  }
}

ex2_latenta_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # randarea inputurilor dinamice
    output$ui_parametri <- renderUI({
      render_parametri_ui(id, input)
    })
    
    # simularea datelor (n redus la 100.000 pt stabilitate)
    date_latenta <- eventReactive(input$btn_sim_latenta, {
      req(input$p1, input$p2)
      n_esantion <- 100000 
      vals <- simuleaza_latenta(n_esantion, input$dist_tip, input$p1, input$p2)
      data.frame(S = vals)
    })
    
    # interpretare valori tabel
    output$text_interpretare_statistici <- renderUI({
      req(date_latenta())
      tagList(
        h4("Interpretare:"),
        tags$ul(
          tags$li(strong("Media:"), " Indica timpul mediu de asteptare. Este sensibila la valorile extreme."),
          tags$li(strong("Varianta:"), " Masoara stabilitatea sistemului. O varianta mare indica latente impredictibile."),
          tags$li(strong("Mediana:"), " Valoarea sub care se afla 50% din cereri. Este cel mai bun indicator pentru experienta tipica."),
          tags$li(strong("Modul:"), " Reprezinta valoarea cea mai frecventa a latentei in sistem.")
        )
      )
    })
    
    # mesaj pentru medie vs mediana
    output$interpretare_text <- renderUI({
      req(date_latenta())
      s_vals <- date_latenta()$S
      medie <- mean(s_vals)
      mediana <- median(s_vals)
      mod_emp <- calculeaza_mod_empiric(s_vals)
      
      tagList(
        h3("Interpretarea Latentelor"),
        p(paste("Analizand esantionul generat, am obtinut o medie de", round(medie, 2), 
                "ms, o mediana de", round(mediana, 2), "ms si valoarea modala de", round(mod_emp, 2), "ms.")),
        
        if (input$dist_tip == "Gamma") {
          tagList(
            h4("Context: Distributie Asimetrica (Gamma)"),
            p("In acest scenariu, media este mai mare decat mediana deoarece distributia este asimetrica la dreapta. "),
            p("Acest lucru reflecta realitatea multor sisteme IT: majoritatea cererilor sunt rapide (mediana), dar exista cateva cereri lente care cresc media generala. "),
            p("Asadar, mediana ofera o imagine mai fidela a experientei utilizatorului obisnuit. ")
          )
        } else {
          tagList(
            h4("Context: Distributie Simetrica (Normala)"),
            p("Media si mediana sunt aproape identice, ceea ce indica un sistem stabil. "),
            p("Intr-un astfel de sistem, performanta este uniforma pentru toti utilizatorii.")
          )
        }
      ) 
    })
    
    # restul output-urilor (Plot și Tabel)
    output$plot_latenta <- renderPlot({
      req(date_latenta(), input$p1, input$p2)
      df <- date_latenta()
      p <- ggplot(df, aes(x = S)) +
        geom_histogram(aes(y = ..density..), bins = 40, fill = "skyblue", color = "white") +
        theme_minimal() +
        labs(title = paste("Densitatea Timpilor de Raspuns (", input$dist_tip, ")"), x = "Timp (ms)")
      
      if (input$dist_tip == "Gamma") {
        p <- p + stat_function(fun = dgamma, args = list(shape = input$p1, rate = input$p2), color = "red", size = 1)
      } else {
        p <- p + stat_function(fun = dnorm, args = list(mean = input$p1, sd = input$p2), color = "darkblue", size = 1)
      }
      p
    })
    
    output$tabel_statistici_latenta <- renderTable({
      req(date_latenta())
      s_vals <- date_latenta()$S
      teor <- statistici_teoretice_latenta(input$dist_tip, input$p1, input$p2)
      data.frame(
        Indicator = c("Medie", "Varianta", "Mediana", "Valoare"),
        Empiric = c(mean(s_vals), var(s_vals), median(s_vals), calculeaza_mod_empiric(s_vals)),
        Teoretic = c(teor$m, teor$v, teor$med, teor$mod)
      )
    })
  })
}