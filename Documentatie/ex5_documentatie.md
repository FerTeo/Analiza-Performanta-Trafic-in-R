# Documentație Cerința 5: Variabile Bidimensionale (N, T) - Discret & Continuu

Autor: Roșca Teodora-Maia

## 1. Descrierea Problemei

Această cerință analizează relația dintre o variabilă discretă și una continuă într-un sistem de reîncercare:
*   $N$: Numărul de încercări (discret).
*   $T$: Timpul total scurs până la finalizare (continuu).

Deoarece fiecare încercare adaugă o latență la timpul total, ne așteptăm la o corelație puternică între cele două. Scopul este cuantificarea acestei relații și vizualizarea ei.

## 2. Aspecte Teoretice

*   **Relația dintre N și T:**
    Matematic, $T$ este o sumă aleatoare de variabile aleatoare:
    $$ T = \sum_{i=1}^{N} L_i $$
    unde $L_i$ este latența încercării $i$. Deoarece $N$ este aleator, $T$ depinde direct de $N$.

*   **Covarianța ($Cov(N, T)$):**
    Măsoară direcția relației liniare.
    *   $Cov > 0$: Când $N$ crește, $T$ tinde să crească.
    *   Definiție: $E[(N - E[N])(T - E[T])]$.
    Dezavantaj: Valoarea depinde de scara de măsură (ms vs secunde).

*   **Coeficientul de Corelație Pearson ($\rho$):**
    Versiunea standardizată a covarianței, cu valori între -1 și 1.
    $$ \rho_{N,T} = \frac{Cov(N, T)}{\sigma_N \sigma_T} $$
    *   $\rho \approx 1$: Corelație pozitivă liniară puternică.

## 3. Reprezentări Grafice

**Boxplot (Distribuție Condiționată):**
Deoarece $N$ ia valori discrete puține (1, 2, 3...), este ideal să vizualizăm distribuția lui $T$ pentru fiecare valoare a lui $N$.
*   Axa X: Numărul de încercări ($N$).
*   Axa Y: Timpul Total ($T$).
*   Fiecare "cutie" arată mediana și dispersia timpului pentru un număr fix de încercări. Se observă clar cum cutiile "urcă" pe axa Y odată cu creșterea lui $N$.

![Alt text](/PozeDocumentatie/ex5_boxplot.png)

## 4. Pachete Software și Surse

### Pachete R utilizate:
*   `stats`: Pachetul de bază din R care conține funcțiile `cor` și `cov`.
*   `ggplot2` & `plotly`:
    *   *Funcționalitate cheie:* `geom_boxplot` pentru vizualizarea relației discret-continuu.

### Surse de informație:
*   Manual R: `?cor`, `?cov`.
*   Statitică descriptivă: Interpretarea coeficientului Pearson.

## 5. Codul și Comentarea Soluției

Soluția este în `R/ex5_variabile_bidim_discrete_si_continue.R`.

### 5.1 Simularea Mixtă

Funcția de simulare generează succesiv latențe și verifică condiția de oprire.

```r
simuleaza_NT <- function(...) {
    # ...
    for(k in 1:total_posibile) {
        # Generare latenta L_k
        l <- rnorm(1, mean=latenta_medie, sd=latenta_sd)
        timp_total <- timp_total + l # T acumuleaza L_k
        
        if(runif(1) <= p_succes) break
    }
    # ...
}
```

### 5.2 Calculul Statisticilor

Folosim funcțiile standard pentru a popula tabelul de rezultate.

```r
cov_val <- cov(df$N, df$T)
cor_val <- cor(df$N, df$T)
```
Rezultatul tipic pentru `cor_val` va fi > 0.9, confirmând legătura mecanică directă dintre numărul de pași și durata totală.

### 5.3 Vizualizarea Boxplot

Este important să tratăm $N$ ca un **factor** (variabilă categorică) pentru ggplot, altfel ar putea încerca să deseneze un scatter plot sau o singură cutie.

```r
# aes(x=factor(N), y=T) este esential
ggplot(df, aes(x=factor(N), y=T, fill=factor(N))) +
    geom_boxplot()
```

## 6. Concluzii

1.  **Liniaritate:** Relația dintre $N$ și $T$ este aproape liniară, deoarece fiecare pas adaugă, în medie, o constantă (media latenței) la timpul total.
2.  **Variabilitate:** Variabilitatea lui $T$ crește ușor odată cu $N$ (suma mai multor variabile aleatoare are o varianță mai mare), lucru vizibil prin "lungirea" cutiilor din boxplot pentru $N$ mare.

