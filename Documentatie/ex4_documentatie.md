# Documentație Cerința 4: Variabile Bidimensionale Discrete (N, F)

Autor: Donea Fernando-Emanuel

## 1. Descrierea Problemei

Această cerință explorează relația dintre două variabile aleatoare discrete într-un proces de autentificare/reîncercare:
*   $N$: Numărul total de încercări efectuate (până la succes sau epuizarea încercărilor).
*   $F$: Numărul de eșecuri întâmpinate.

Scopul este analiza distribuției comune (joint distribution) a perechii $(N, F)$ și verificarea independenței statistice dintre cele două variabile.

## 2. Aspecte Teoretice

*   **Variabila Aleatoare Bidimensională $(X, Y)$:**
    Este o funcție care asociază fiecărui rezultat din spațiul de eșantionare o pereche de numere reale. În cazul nostru, spațiul este discret.
    Probabilitatea comună este $P(N=n, F=f)$.

*   **Distribuții Marginale:**
    Probabilitatea de a observa doar una dintre variabile, ignorând-o pe cealaltă.
    $$ P(N=n) = \sum_{f} P(N=n, F=f) $$

*   **Independența:**
    Două variabile sunt independente dacă $P(N=n, F=f) = P(N=n) \times P(F=f)$ pentru orice pereche $(n, f)$.
    Invers, dependența înseamnă că informația despre una ne influențează cunoștințele despre cealaltă.

*   **Testul Chi-Square ($\chi^2$) de Independență:**
    Un test statistic pentru a verifica dacă există o asociere semnificativă între două variabile categorice/discrete.
    *   Ipoteza nulă ($H_0$): Variabilele sunt independente.
    *   Dacă $p-value < 0.05$, respingem $H_0$ și conchidem că sunt dependente.

## 3. Reprezentări Grafice

1.  **Heatmap (Distribuția Comună):**
    *   O matrice colorată unde intensitatea culorii reprezintă probabilitatea $P(N, F)$.
    *   Permite vizualizarea rapidă a combinațiilor frecvente (ex: $N=1, F=0$ pentru succes din prima).

2.  **Grafice Marginale:**
    *   Histograma pentru $N$ și Histograma pentru $F$ separate.
    *   Arată comportamentul individual al fiecărei variabile.

## 4. Pachete Software și Surse

### Pachete R utilizate:
*   `reshape2`: Funcția `melt` (implicită în manipularea dataframe-urilor pentru ggplot) este adesea folosită pentru a transforma matrici în format "long" pentru vizualizare. Aici folosim transformarea tabelului de frecvență.
*   `plotly`: Pentru heatmap interactiv.
    *   *Funcționalitate cheie:* `ggplotly` cu tooltip personalizat (`text = ...`) pentru a afișa probabilitatea exactă la mouse hover.
*   `gridExtra`: Pentru a afișa graficele marginale unul lângă altul (`grid.arrange`).

### Surse de informație:
*   Manual R: `?chisq.test`, `?table`.
*   Teoria Probabilităților: Definiția independenței variabilelor aleatoare.

## 5. Codul și Comentarea Soluției

Soluția este implementată în `R/ex4_variabile_bidim_discrete.R`.

### 5.1 Algoritmul de Simulare

Simularea reflectă procesul logic: executăm încercări până la succes sau până la limita maximă.
Variabilele $N$ și $F$ sunt calculate la fiecare pas.

```r
simuleaza_NF <- function(...) {
    # ...
    for(k in 1:total_posibile) {
        if(runif(1) <= p_succes) {
            # Succes la incercarea k
            n_curent <- k
            f_curent <- k - 1 # Au fost k-1 esecuri inainte
            break
        }
        # In caz de esec, continuam
    }
    # ...
}
```

### 5.2 Construirea Heatmap-ului

Transformăm tabelul de contingență într-un `data.frame` pentru a-l putea plota cu `ggplot2`.

```r
# Tabela de frecventa (contingenta)
tbl <- table(factor(df$N), factor(df$F))
# Conversie pentru ggplot
df_heatmap <- as.data.frame(tbl) 
# Calcul probabilitati
df_heatmap$Probabilitate <- df_heatmap$Frecventa / sum(df_heatmap$Frecventa)

# Plotare
ggplot(df_heatmap, aes(x=N, y=F, fill=Probabilitate)) + geom_tile() ...
```

### 5.3 Testul de Independență

Folosim funcția nativă `chisq.test` pe tabelul de contingență.

```r
test <- chisq.test(table(df$N, df$F))
```
În acest caz, testul va returna aproape mereu un p-value foarte mic, confirmând dependența puternică. (Logic: $F$ nu poate fi mai mare sau egal cu $N$ dacă ultima încercare e succes, și $F$ depinde direct de câte încercări fac).

## 6. Concluzii

1.  **Dependența Puternică:** $N$ și $F$ sunt intrinsec legate. Cunoașterea numărului de încercări ($N$) oferă informații precise despre numărul posibil de eșecuri ($F$), restrângând domeniul posibil la $\{N-1, N\}$.
2.  **Vizualizarea:** Heatmap-ul evidențiază clar faptul că doar anumite perechi $(N, F)$ sunt posibile (diagonala și sub-diagonala), restul având probabilitate zero.

