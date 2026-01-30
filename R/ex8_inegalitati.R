verificare_inegalitati <- function(df_simulare, prag_timp_markov, k_deviatii_cebisev) {
    #timpul din dataframe
    valori_T <- df_simulare$T
    
    # calculam statistici pe datele simulate (empiric)
    Media_T      <- mean(valori_T)
    Varianta_T   <- var(valori_T)
    DeviatiaStd_T <- sd(valori_T) # sigma
    
    # 1. Markov: 
    # "probabilitatea ca T sa fie foarte mare este limitata de Medie / Prag
    # P(T >= a) <= E[T] / a
    
    
    calcul_Markov_stanga <- mean(valori_T >= prag_timp_markov)  # P(T >= a) empiric
    

    calcul_Markov_dreapta <- Inf
    if (prag_timp_markov > 0) {
        calcul_Markov_dreapta <- Media_T / prag_timp_markov
    }
    
    check_Markov <- FALSE
    if (calcul_Markov_stanga <= calcul_Markov_dreapta) {
        check_Markov <- TRUE
    }
    
    # 2 Cebisev 
    # probabilitatea ca T sa fie departe de medie este mica
    # P(|T - Medie| >= k * sigma) <= 1 / k^2
    
    distanta_fata_de_medie <- abs(valori_T - Media_T)
    prag_distanta <- k_deviatii_cebisev * DeviatiaStd_T
    
    calcul_Cebisev_stanga <- mean(distanta_fata_de_medie >= prag_distanta)
    calcul_Cebisev_dreapta <- 1 / (k_deviatii_cebisev^2)
    
    check_Cebisev <- FALSE
    if (calcul_Cebisev_stanga <= calcul_Cebisev_dreapta) {
        check_Cebisev <- TRUE
    }
    
    # 3 Jensen:
    # media patratelor este mai mare decat patratul mediei (pentru functia convexa x^2)
    # phi(E[T]) <= E[phi(T)]
    
    # functia convexa aleasa: f(x) = x^2
    Media_T_la_patrat <- Media_T^2                  # (E[T])^2
    Media_Patratelor_T <- mean(valori_T^2)          # E[T^2]
    
    check_Jensen <- FALSE
    if (Media_T_la_patrat <= Media_Patratelor_T) {
        check_Jensen <- TRUE
    }
    
    return(list(
        Markov = list( Empiric_P_Mare = calcul_Markov_stanga, Limita_Teoretica = calcul_Markov_dreapta, Respectat = check_Markov),
        Cebisev = list(Empiric_P_Outlier = calcul_Cebisev_stanga, Limita_Teoretica = calcul_Cebisev_dreapta, Respectat = check_Cebisev),
        Jensen = list( Patratul_Mediei = Media_T_la_patrat, Media_Patratelor = Media_Patratelor_T, Respectat = check_Jensen)
    ))
}
