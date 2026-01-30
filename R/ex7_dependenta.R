simuleaza_dependenta <- function(nr_simulari, prob_succes_per_try, latenta_medie_initiala, nr_max_retry, factor_penalizare_latenta = 1.5) {
    
    vector_SuccesFinal <- numeric(nr_simulari) 
    vector_TimpTotal   <- numeric(nr_simulari) 
    
    for (i in 1:nr_simulari) {
        este_succes <- FALSE
        timp_acumulat <- 0
        
        # incepem cu rata normala (lambda = 1 / medie)
        rata_exponentiala_curenta <- 1 / latenta_medie_initiala 
        
        for (nr_retry in 0:nr_max_retry) {
            # generam latenta pentru aceasta incercare (S_i)
            # timpul este aleator exponential
            timp_raspuns_curent <- rexp(1, rate = rata_exponentiala_curenta)
            timp_acumulat <- timp_acumulat + timp_raspuns_curent
            
            # verif daca cererea a reusit
            # runif(1) genereaza un nr intre 0 si 1. Daca e < prob_succes, consideram succes.
            if (runif(1) <= prob_succes_per_try) {
                este_succes <- TRUE
                break 
            } else {
                # daca am ajuns aici: esec
                # logica de dependenta: "latenta creste dupa esecuri"
                # daca factor_penalizare > 1, scadem rata (ceea ce creste media timpului)
                rata_exponentiala_curenta <- rata_exponentiala_curenta / factor_penalizare_latenta
            }
        }
        
        vector_SuccesFinal[i] <- as.integer(este_succes)
        vector_TimpTotal[i]   <- timp_acumulat
    }
    return(data.frame(I = vector_SuccesFinal, T = vector_TimpTotal))
}
