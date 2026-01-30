calculeaza_conditionate <- function(df_simulare, prag_retry_mic, prag_timp_bun = 200) {
    col_Succes <- df_simulare$I # succes final din dataframe
    col_TimpTotal <- df_simulare$T # timp total pana la succes sau abandon
    col_NrIncercari <- df_simulare$N # nr de incercari
    # a)
    
    # a) P(A | N <= n0) = P(A si N <= n0) / P(N <= n0)
    
    # P(N <= n0)
    prob_Conditie_N <- mean(col_NrIncercari <= prag_retry_mic)
    
    # P(A si N <= n0)
    prob_Intersectie_A_N <- mean((col_Succes == 1) & (col_NrIncercari <= prag_retry_mic))
    
    # P(A | N <= n0)
    prob_Succes_cond_RetryMic <- 0
    if (prob_Conditie_N > 0) {
        prob_Succes_cond_RetryMic <- prob_Intersectie_A_N / prob_Conditie_N
    }

    #a) P(B | A)
    
    # P(A)
    prob_Conditie_A <- mean(col_Succes == 1)
    
    # P(B si A)
    prob_Intersectie_B_A <- mean((col_TimpTotal <= prag_timp_bun) & (col_Succes == 1))
    
    # P(B | A)
    prob_TimpBun_cond_Succes <- 0
    if (prob_Conditie_A > 0) {
        prob_TimpBun_cond_Succes <- prob_Intersectie_B_A / prob_Conditie_A
    }
    
    
    # b) Calculati mediile conditionate: E(T | I=1) si E(T | I=0)
    # Adica: Timpul mediu cand avem Succes vs Timpul mediu cand avem Esec
    
    # Formula: E[T | I=1] = E[T * I] / P(I=1)
    # Obs: T * I este valoarea T cand I=1, si 0 cand I=0.
    
    # 1. Calculam numaratorul E[T * I] pentru Succes
    # Pentru Esec (I=0), indicatorul e (1 - I).
    media_T_ori_I_Succes <- mean(col_TimpTotal * col_Succes) 
    media_T_ori_I_Esec   <- mean(col_TimpTotal * (1 - col_Succes))
    
    # 2. Numitorul este P(I=1) aka prob_Conditie_A calculat mai sus
    prob_I_0 <- mean(col_Succes == 0) # P(I=0)
    
    medie_Timp_la_Succes <- 0
    if (prob_Conditie_A > 0) {
        medie_Timp_la_Succes <- media_T_ori_I_Succes / prob_Conditie_A
    }
    
    medie_Timp_la_Esec <- 0
    if (prob_I_0 > 0) {
        medie_Timp_la_Esec <- media_T_ori_I_Esec / prob_I_0
    }
    
    
    return(list(
        Probabilitate_Succes_daca_Retry_Mic = prob_Succes_cond_RetryMic,
        Probabilitate_TimpBun_daca_Succes   = prob_TimpBun_cond_Succes,
        Timp_Mediu_Succes = medie_Timp_la_Succes,
        Timp_Mediu_Esec = medie_Timp_la_Esec
    ))
}

