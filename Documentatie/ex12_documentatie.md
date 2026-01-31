# Documentație Cerința 12: Vizualizare Statistică Avansată și Analiza Profitului

Autor: Roșca Teodora-Maia

## 1. Descrierea Problemei

Această cerință integrează toate conceptele anterioare într-o simulare economică completă.
Obiectivul este de a evalua viabilitatea unui proces de business ținând cont de:
1.  **Timp ($T$):** Resursă consumată (latenta cumulată).
2.  **Rezultat ($Outcome$):** Succes sau Eșec.
3.  **Profit:** Un scor compus care recompensează succesul și penalizează timpul și reîncercările.

Accentul cade pe vizualizarea avansată a distribuțiilor și identificarea valorilor atipice (outliers) care pot destabiliza sistemul.

## 2. Aspecte Teoretice

*   **IQR (Interquartile Range) și Outliers:**
    Metoda "Tukey Fences" pentru detectarea anomaliilor:
    *   $IQR = Q_3 - Q_1$ (diferența dintre percentila 75% și 25%).
    *   Intervalul "normal" este $[Q_1 - 1.5 \times IQR, Q_3 + 1.5 \times IQR]$.
    *   Orice valoare în afara acestui interval este considerată **Outlier** (valoare extremă).

*   **Analiza Condiționată:**
    Compararea distribuției unei variabile continue ($T$) separat pentru fiecare categorie a unei variabile discrete ($Outcome$). Aceasta ne permite să răspundem la întrebări de genul: "Durează mai mult eșecurile decât succesurile?"

## 3. Reprezentări Grafice

1.  **Histograme Combinate (Subplots):**
    Utilizăm `plotly` pentru a afișa simultan distribuția Timpului și a Profitului. Acestea permit observarea formei distribuției (ex: multimodală, asimetrică).

![Alt text](/PozeDocumentatie/ex12_histograme_combinate.png)
    

2.  **Boxplot Condiționat:**
    *   Axa X: Rezultatul (Succes / Eșec).
    *   Axa Y: Timpul ($T$).
    *   Permite comparația directă a medianelor și a dispersiei între cele două scenarii. De obicei, eșecurile au mediane mai mari (deoarece implică epuizarea tuturor reîncercărilor).
  
![Alt text](/PozeDocumentatie/ex12_boxplot.png)

## 4. Pachete Software și Surse

### Pachete R utilizate:
*   `plotly`:
    *   *Funcționalitate cheie:* `subplot` pentru a alipi mai multe grafice interactive în același cadru.
*   `ggplot2`:
    *   *Funcționalitate cheie:* `scale_fill_manual` pentru a controla culorile (Verde pentru Succes, Roșu pentru Eșec).

### Surse de informație:
*   Statistica Exploratorie: Definiția și utilizarea IQR pentru outliers.
*   Documentația Plotly R: Funcția `subplot`.

## 5. Codul și Comentarea Soluției

Soluția se află în `R/ex12_vizualizare.R`.

### 5.1 Calculul Profitului

Logica de business este încapsulată în calculul profitului pentru fiecare simulare:

```r
# Profit = Recompensa - Cost_Timp - Cost_Retry
val_reward <- if(succes) reward_success else 0
profit <- val_reward - (cost_time * timp_total) - (cost_retry * n_attempts)
```
Această formulă transformă metricile tehnice ($N, T$) într-o metrică de business.

### 5.2 Detectarea Outlierilor

Am implementat o funcție helper `calc_stats` care aplică algoritmul IQR:

```r
calc_stats <- function(x) {
    q1 <- quantile(x, 0.25)
    q3 <- quantile(x, 0.75)
    iqr_val <- q3 - q1
    lim_inf <- q1 - 1.5 * iqr_val
    lim_sup <- q3 + 1.5 * iqr_val
    # Numaram cate valori ies din interval
    outliers <- sum(x < lim_inf | x > lim_sup)
    # ...
}
```
Această funcție generează tabelul statistic detaliat afișat în interfață.

### 5.3 Vizualizarea Complexă

Folosim `subplot` pentru a crea un dashboard compact.

```r
# p1 si p2 sunt obiecte ggplot standard
subplot(ggplotly(p1), ggplotly(p2), nrows = 2, ...)
```

## 6. Concluzii

1.  **Impactul Eșecurilor:** Eșecurile sunt "dublu" penalizatoare: nu aduc recompensă și, de regulă, consumă cel mai mult timp (toate retry-urile posibile).
2.  **Identificarea Riscurilor:** Analiza outlierilor arată că, deși media profitului poate fi pozitivă, există cazuri rare (outliers negativi) care pot genera pierderi semnificative.

