# Documentație Cerința 9: Aproximarea Normală (Teorema Limită Centrală)

## AUTOR : Bulacu Daria 

## 1. Descrierea Problemei

Această cerință își propune să analizeze comportamentul agregat al sistemului pe o perioadă extinsă de timp (de exemplu, un an sau mai mulți). Într-un sistem real, numărul zilnic de clienți este o variabilă aleatoare (modelată aici printr-un proces Poisson), iar rezultatul interacțiunii fiecărui client cu sistemul (latenta, succesul/eșecul, profitul generat) este, de asemenea, o variabilă aleatoare.

Scopul este de a studia distribuția sumelor acestor variabile aleatoare (ex: profitul total zilnic sau latența totală acumulată). Conform Teoremei Limită Centrale (CLT), ne așteptăm ca, pentru un număr mare de evenimente independente, această distribuție agregată să conveargă către o distribuție Normală (Gaussiana). Validarea acestei ipoteze permite simplificarea analizelor viitoare: în loc să rulăm simulări complexe Monte Carlo pentru fiecare scenariu, putem folosi formulele analitice ale distribuției Normale (bazate pe medie și deviație standard) pentru a estima riscurile și performanța.

## 2. Aspecte Teoretice



*   **Procese Poisson Neomogene:**
    Numărul de clienți $N(t)$ care sosesc într-o zi este modelat folosind o distribuție Poisson cu o rată $\lambda(t)$ care variază în funcție de sezonalitate (anotimp). Aceasta reflectă natura aleatoare a cererii într-un sistem de servere.

*   **Variabile Aleatoare Compuse (Compound Random Variables):**
    Variabila de interes $S$ (suma agregată pe zi) este definită ca:
    $$ S = \sum_{i=1}^{N} X_i $$
    Unde:
    *   $N$ este numărul aleator de clienți (Poisson).
    *   $X_i$ sunt variabile aleatoare independente și identic distribuite (i.i.d.) reprezentând rezultatul pentru clientul $i$ (profit sau latență).
    Aceasta este o sumă aleatoare de variabile aleatoare, un concept central în teoria riscului și teoria cozilor.

*   **Teorema Limită Centrală (CLT):**
    Această teoremă fundamentală afirmă că suma (sau media) a unui număr mare de variabile aleatoare independente și identic distribuite tinde către o distribuție normală, indiferent de forma distribuției originale a variabilelor individuale (cu condiția să aibă varianță finită).
    $$ \frac{S_n - n\mu}{\sigma\sqrt{n}} \xrightarrow{d} N(0, 1) $$
    În contextul nostru, chiar dacă latența individuală este exponențială (sau Gamma) și numărul de clienți este Poisson, distribuția totalului zilnic va avea o formă de "clopot" (Gaussiana).

## 3. Reprezentări Grafice

Proiectul include vizualizări esențiale pentru validarea ipotezei de normalitate:

1.  **Histograma cu Curba de Densitate Suprapusă:**
    *   Barele albastre reprezintă frecvența empirică a valorilor simulate (profit sau latență zilnică).
    *   Linia roșie continuă reprezintă curba teoretică a distribuției Normale, având aceeași medie și deviație standard ca datele simulate. Suprapunerea vizuală confirmă validitatea aproximării.

2.  **QQ Plot (Quantile-Quantile Plot):**
    *   Un instrument de diagnostic statistic care compară cuantilele distribuției empirice cu cuantilele distribuției Normale teoretice.
    *   Dacă punctele albastre se aliniază pe diagonala de referință (linia roșie), datele urmează o distribuție Normală. Abaterile la capete (cozi) indică "fat tails" sau asimetrii.

## 4. Pachete Software și Surse de Inspirație

### Pachete R utilizate:
*   `dplyr`: Pentru manipularea eficientă a datelor (agregări, filtrări).
*   `ggplot2`: Pentru generarea graficelor avansate (histograme, QQ plots).
*   `shiny`: Pentru interfața grafică interactivă.
*   `stats` (pachet de bază): Pentru funcțiile `rpois` (generare Poisson), `dnorm` (densitate normală), `sd` (deviație standard).

### Surse de inspirație:
*   Modelarea traficului și a cozilor a fost inspirată din lucrările lui Sheldon Ross privind procesele stocastice.
*   Implementarea vizuală a histogramei suprapuse cu densitatea normală urmează practicile standard din analiza exploratorie a datelor (EDA) în R.

## 5. Codul și Comentarea Soluției

Codul este structurat modular. Funcțiile principale se află în `R/ex9_an_agregare.R`.

### 5.1 Generarea Traficului cu Sezonalitate
Funcția `genereaza_trafic_integrat` simulează numărul de clienți pentru fiecare zi, aplicând factori de multiplicare în funcție de anotimp.

```r
genereaza_trafic_integrat <- function(nr_zile, lambda_baza) {
    vec_luni <- rep(rep(1:12, each = 30), length.out = nr_zile)
    vec_anotimpuri <- sapply(vec_luni, get_anotimp)

    # factori de sezonalitate conform logicii ex1
    map_factor <- c("Iarna" = 0.8, "Primavara" = 1.0, "Vara" = 1.5, "Toamna" = 1.1)
    vec_factori <- map_factor[vec_anotimpuri]

    #vector care contine media fiecarei zi conform anotimpului, deci in final anului,
    #in functie de lambda_baza care reprez media generala de clienti  
    lambda_vec <- lambda_baza * vec_factori
  
    
    #genereaza numarul efectiv de clienti per zilele din anotimpuri urmarite de trafic
    trafic_zilnic <- rpois(nr_zile, lambda = lambda_vec)

    return(trafic_zilnic)
}
```

### 5.2 Simularea Agregată
Funcția `genereaza_agregat_zilnic_integrat` este nucleul simulării. Pentru fiecare zi, simulează comportamentul detaliat al fiecărui client (folosind `simuleaza_evenimente` din exercițiile anterioare) și agregă rezultatele.

```r
genereaza_agregat_zilnic_integrat <- function(nr_zile, lambda_mediu,
                                              prob_succes, medie_latenta, nr_max_retry,
                                              tip_analiza = "profit", # "profit" sau "latenta"
                                              params_eco = list()) {
    #generam numarul de clienti pe zile 
    clienti_pe_zile <- genereaza_trafic_integrat(nr_zile, lambda_mediu)

    rezultate_zilnice <- numeric(nr_zile)

    #iteram prin fiecare zi pentru a analiza cum activitatea individuala a unui client 
    #influenteaza activitatea firmei pe acea zi 
    for (zi in 1:nr_zile) {
        nr_clienti_azi <- clienti_pe_zile[zi]
        if (nr_clienti_azi > 0) {
          #simulam comportamentul a nrului de clienti efectiv pe acea zi cu prob de succes X si latenta Y 
            df_zi <- simuleaza_evenimente(
                nr_simulari = nr_clienti_azi,
                prob_succes = prob_succes,
                medie_latenta = medie_latenta,
                nr_max_retry = nr_max_retry
            )
            #comanda pentru UI in Shiny pentru afisare de latenta sau profit 

            if (tip_analiza == "latenta") {
                #suma latentelor calculata pe coloana T, pt a obt nr total de ms consumate de server in acea zi 
                rezultate_zilnice[zi] <- sum(df_zi$T)
            } else {
                # calculam profitul pentru logica economica din spatele ex 11
                # params_eco conține: castig, pierdere, t_sla, penalitate

                # venit (I==1)
                venit <- sum(df_zi$I == 1) * params_eco$castig

                # pierderi Churn  (I==0)
                pierdere <- sum(df_zi$I == 0) * params_eco$pierdere

                # penalitatile SLA (I==1 si T>t_sla)
                slas_incalcate <- sum(df_zi$I == 1 & df_zi$T > params_eco$t_sla)
                amenda <- slas_incalcate * params_eco$penalitate

                rezultate_zilnice[zi] <- venit - pierdere - amenda
            }
        } else {
            rezultate_zilnice[zi] <- 0
        }
    }

    return(data.frame(zi = 1:nr_zile, valoare = rezultate_zilnice))
}
```

### 5.3 Determinarea Parametrilor Normali
Funcția `test_aproximare_normala` calculează parametrii distribuției normale echivalente.

```r
test_aproximare_normala <- function(vals) {
  medie_emp <- mean(vals)
  sd_emp <- sd(vals)
  # returneaza parametrii pentru desenarea curbei teoretice
  list(
    medie = medie_emp,
    sd = sd_emp
  )
}
```

## 6. Concluzii

Implementarea Cerinței 9 demonstrează cu succes aplicabilitatea Teoremei Limită Centrale în analiza performanței sistemelor informatice.
1.  Prin agregarea datelor pe perioade lungi, distribuțiile complexe (timpi de așteptare exponențiali, sosiri Poisson) converg către o distribuție Normală predictibilă.
2.  Vizualizările (Histograma și QQ Plot) confirmă vizual această convergență.
3.  Aceasta permite managerilor să facă predicții statistice robuste (ex: "Există o probabilitate de 95% ca profitul zilnic să fie între X și Y") fără a rula simulări exhaustive de fiecare dată.

## 7. Bibliografie

Fundamentarea teoretică a algoritmilor utilizați în Cerința 9 se bazează pe lucrări de referință din domeniul probabilităților și statisticii inginerești.

**A. Surse Bibliografice (Cărți și Tratate)**

*   **Pentru Procesele Poisson și Modelarea Traficului:**
    *   **Referință:** Ross, S. M. (2014). *Introduction to Probability Models* (11th Edition). Academic Press.
    *   **Utilizare în proiect:** Capitolul 5 ("The Poisson Process") a servit ca sursă primară pentru justificarea utilizării distribuției Poisson în generarea sosirii clienților ($N(t)$), precum și pentru conceptul de "Proces Poisson Compus" utilizat în agregarea datelor.

*   **Pentru Teorema Limită Centrală și Convergență:**
    *   **Referință:** Rosenthal, J. S. (2006). *A First Look at Rigorous Probability Theory*. World Scientific.
    *   **Utilizare în proiect:** Teoremele referitoare la convergența în distribuție (Weak Convergence) au fost utilizate pentru a justifica de ce suma timpilor de așteptare (variabile Gamma/Exponențiale) tinde asimptotic către o distribuție Normală, permițând astfel aproximarea Gaussiana.

*   **Pentru Metodele de Simulare Monte Carlo:**
    *   **Referință:** Kroese, D. P., Taimre, T., & Botev, Z. I. (2011). *Handbook of Monte Carlo Methods*. John Wiley & Sons.
    *   **Utilizare în proiect:** Principiile generale de generare a numerelor pseudo-aleatoare și estimarea mediei empirice prin eșantionare repetată.

*   **Vizualizarea Teoremei Limită Centrale:**
    *   **Sursă:** Khan Academy – "Central Limit Theorem visualization".
    *   **Descriere:** Materialele video au fost folosite pentru a înțelege intuitiv comportamentul mediei de eșantionare ("Sampling Distribution of the Sample Mean").

*   **Documentația Tehnică R (Software):**
    *   **Sursă:** The R Project for Statistical Computing (cran.r-project.org).
    *   **Referință:** Documentația oficială a pachetului `stats` pentru funcțiile de densitate `dnorm`, `qnorm` și `rpois`.

*   **Galton Board (Placa lui Galton):**
    *   **Concept vizual:** S-a utilizat analogia fizică a "Plăcii lui Galton" (Galton Board / Quincunx) ca inspirație pentru graficele de histogramă. Așa cum bilele care cad aleatoriu formează un clopot fizic, datele agregate ale clienților din simulare formează clopotul statistic în `ggplot2`.
