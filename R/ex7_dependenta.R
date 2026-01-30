# Ex 7: Independenta vs Dependenta
# Scenariul 2 din cerinta: "Dependenta (latenta creste dupa esecuri)"
# Asta simuleaza un sistem "congestionat" unde retry-urile dureaza mai mult

simuleaza_dependenta <- function(nr_simulari, prob_succes_per_try, latenta_medie_initiala, nr_max_retry, factor_penalizare_latenta = 1.5) {
    # Vom stoca rezultatele in acesti vectori
    vector_SuccesFinal <- numeric(nr_simulari) # I din enunt
    vector_TimpTotal   <- numeric(nr_simulari) # T din enunt
    
    for (i in 1:nr_simulari) {
        este_succes <- FALSE
        timp_acumulat <- 0
        
        # Incepem cu rata normala (lambda = 1 / medie)
        rata_exponentiala_curenta <- 1 / latenta_medie_initiala 
        
        # Iteram prin incercari (0 = prima incercare, 1 = primul retry, etc)
        for (nr_retry in 0:nr_max_retry) {
            # Generam latenta pentru aceasta incercare (S_i)
            # Timpul este aleator exponential
            timp_raspuns_curent <- rexp(1, rate = rata_exponentiala_curenta)
            timp_acumulat <- timp_acumulat + timp_raspuns_curent
            
            # Verificam daca cererea a reusit
            # runif(1) genereaza un nr intre 0 si 1. Daca e < prob_succes, consideram succes.
            if (runif(1) <= prob_succes_per_try) {
                este_succes <- TRUE
                break # Iesim din bucla de retry, am terminat cu succes
            } else {
                # ESEC LA ACEASTA INCERCARE
                # Logica de dependenta: "latenta creste dupa esecuri"
                # Daca factor_penalizare > 1, scadem rata (ceea ce creste media timpului)
                # Exemplu: daca factor = 2, timpul mediu se dubleaza la urmatoarea incercare
                rata_exponentiala_curenta <- rata_exponentiala_curenta / factor_penalizare_latenta
            }
        }
        
        vector_SuccesFinal[i] <- as.integer(este_succes)
        vector_TimpTotal[i]   <- timp_acumulat
    }
    
    # Returnam in formatul standard I, T pentru compatibilitate
    return(data.frame(I = vector_SuccesFinal, T = vector_TimpTotal))
}
