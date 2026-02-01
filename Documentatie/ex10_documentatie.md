# Documentație Cerința 10: Churn (Pierderea Utilizatorilor)

AUTOR : Donea Fernando-Emanuel




Pierderea utilizatorilor se realizează prin două mecanisme: aleator(cu o probabilitate constantă 𝑞) și respectiv condiționat, dacă într-o fereastră de 𝑚 cereri, cel puțin 𝑘 eșuează.
- a) Modelați probabilistic cele două scenarii.
- b) Estimați probabilitatea de pierdere a utilizatorului.
- c) Comparați scenariile și interpretați.

## 1. Descrierea Problemei

"Churn"-ul (rata de abandon) este o metrică critică pentru orice serviciu digital. Utilizatorii renunță la un serviciu din diverse motive, care pot fi împărțite în două categorii majore:
1.  **Cauze Exogene (Aleatoare):** Decizii independente de calitatea tehnică a serviciului (ex: schimbarea intereselor, oferte mai bune de la competiție).
2.  **Cauze Endogene (Condiționate de Calitate):** Frustrarea acumulată din cauza erorilor tehnice repetate. Utilizatorii sunt dispuși să tolereze erori ocazionale, dar un "șir" de eșecuri într-un interval scurt ii determină să părăsească platforma.

Această cerință modelează probabilistic ambele scenarii pentru a ajuta la înțelegerea riscurilor și a impactului stabilității sistemului asupra reținerii clienților pe termen lung.

## 2. Aspecte Teoretice

Modelele matematice utilizate sunt:

*   **Modelul Aleator (Geometric):**
    Presupunem că la fiecare pas de timp (sau interacțiune), utilizatorul pleacă cu o probabilitate constantă $q$, independent de istoric.
    Timpul până la churn, $T_{churn}$, urmează o **distribuție Geometrică**:
    $$ P(T_{churn} = n) = (1-q)^{n-1} q $$
    Probabilitatea de a rămâne activ după $n$ pași este $(1-q)^n$.

*   **Modelul Condiționat (Fereastră Alunecătoare):**
    Utilizatorul pleacă dacă, într-o fereastră de $m$ cereri consecutive, se înregistrează cel puțin $k$ eșecuri.
    Fie $X_i$ o variabilă Bernoulli ($1$ = eșec, $0$ = succes) cu $P(X_i = 1) = p_{fail}$.
    Condiția de churn la momentul $t$ este:
    $$ \sum_{j=t-m+1}^{t} X_j \ge k $$
    Acesta este un proces  mai complex, dependent de numărul de eșecuri consecutive. Churn-ul nu este o decizie instantanee, ci rezultatul unei degradări locale a calității serviciului.

## 3. Reprezentări Grafice

Analiza vizuală compară curbele de supraviețuire (sau complementul lor, curbele de churn) pentru cele două scenarii:

1.  **Evoluția Probabilității de Churn:**
    *   Un grafic liniar care arată cum crește probabilitatea cumulată ca un utilizator să fi părăsit sistemul până la pasul $t$.
    *   **Scenariul Aleator:** O curbă lină, logaritmică, care tinde asimptotic spre 1.
    *   **Scenariul Condiționat:** O curbă neregulată, dependentă de apariția aleatoare a clusterelor de erori. De obicei, are o pantă mai abruptă la început (dacă $p_{fail}$ e mare) sau rămâne plată mult timp (dacă sistemul e stabil).
    ![](/PozeDocumentatie/ex10_grafic_churn.png)

## 4. Pachete Software

*   **Simulare și Manipulare Date:** `stats` (pentru generarea seriilor `rbinom` și `runif`) și `dplyr` pentru procesarea rezultatelor.
*   **Vizualizare:** `ggplot2` și `plotly` pentru grafice interactive care permit compararea directă a seriilor de timp.
*   **Logica Ferestrelor:** Funcția `stats::filter` este utilizată pentru a calcula eficient suma erorilor pe vectorul de rezultate.

## 5. Codul și Comentarea Soluției

Soluția este implementată în `R/ex10_churn.R`.

### 5.1 Simularea Churn-ului Aleator
Simluăm comportamentul a `sims` utilizatori pe `N` pași. Generăm o matrice de probabilități uniforme și verificăm condiția de ieșire ($val < q$).

```r
simulate_churn_random <- function(N, q, sims) {
    # matrice random (sims x N)
    random_vals <- matrix(runif(sims * N), nrow = sims, ncol = N)
    
    # identificam pasii unde are loc evenimentul churn
    churn_matrix <- random_vals < q
    
    # gasim PRIMUL moment de churn pentru fiecare utilizator
    # functia max.col returneaza indexul primei valori TRUE
    first_churn <- max.col(churn_matrix, ties.method = "first")
    return(first_churn)
}
```

### 5.2 Simularea Churn-ului Condiționat
Aceasta necesită generarea prealabilă a erorilor sistemului și apoi verificarea ferestrelor.

```r
simulate_churn_conditional <- function(N, m, k, p_fail, sims) {
    # generam matricea de esecuri tehnice (1/0)
    failures <- matrix(rbinom(sims * N, 1, p_fail), nrow = sims, ncol = N)

    results <- apply(failures, 1, function(row) {
        # calculam suma mobila (rolling sum) pe fereastra de marime m
        rsum <- stats::filter(row, rep(1, m), sides = 1)
        
        # identificam momentele unde s-a depasit pragul k de erori
        idx <- which(rsum >= k)
        
        # returnam primul moment (daca exista)
        if (length(idx) > 0) return(idx[1]) else return(NA)
    })
    return(results)
}
```

### 5.3 Compararea Scenariilor
Serverul Shiny (`ex10_churn_server`) agregă rezultatele acestor simulări pentru a calcula probabilitatea empirică cumulată:
$$ P(Churn \le t) = \frac{\text{Număr utilizatori pierduți până la } t}{\text{Număr total simulări}} $$
Aceasta permite o comparație directă: "Care mecanism este mai periculos pentru afacere pe termen scurt vs. lung?".

## 6. Concluzii

1.  **Diferența de Dinamică**: Churn-ul aleator este o pierdere constantă - chiar și cu $q$ mic, pe o perioadă lungă, pierderea este garantată. Churn-ul condiționat este sporadic - un sistem stabil ($p_{fail}$ mic) poate reține utilizatorii aproape indefinit.
2.  **Sensibilitatea la Erori**: Scenariul condiționat demonstrează de ce stabilitatea tehnică este vitală. O creștere mică a ratei de eroare ($p_{fail}$) poate declanșa o pierdere masivă de utilizatori dacă aceștia au toleranță scăzută (fereastră $m$ mică, prag $k$ mic).
3.  **Optimizare**: Pentru a reduce churn-ul, managerii pot acționa pe două planuri:
    *   Marketing/Fidelizare (pentru a reduce $q$).
    *   Inginerie/SRE (pentru a reduce $p_{fail}$ și a preveni gruparea erorilor).

