# Documentație Cerința 2: Modelarea Timpilor de Răspuns (Variabile Continue)

Autor: Donea Fernando-Emanuel

## 1. Descrierea Problemei

Această cerință abordează modelarea timpilor de răspuns (latența) într-un sistem de servire. Timpul de răspuns este o variabilă continuă esențială pentru evaluarea performanței (Quality of Service).
Obiectivul este de a simula acești timpi folosind distribuții de probabilitate continue și de a analiza proprietățile lor statistice (media, varianța, mediana, modul). De asemenea, se dorește compararea distribuțiilor simetrice (Normală) cu cele asimetrice (Gamma), care sunt adesea modele mai realiste pentru latență (unde există valori "coadă lungă" - long tail).

## 2. Aspecte Teoretice

Modelarea se bazează pe variabile aleatoare continue:

*   **Distribuția Gamma:**
    Este adesea utilizată pentru a modela timpii de așteptare. Este definită de doi parametri:
    *   Forma ($\alpha$ sau `shape`): controlează forma distribuției.
    *   Rata ($\beta$ sau `rate`): inversul scalei.
    Media este $E[X] = \alpha / \beta$, iar Varianța $Var(X) = \alpha / \beta^2$. Este potrivită pentru fenomene unde valorile sunt strict pozitive și asimetrice.

*   **Distribuția Normală (Gaussiană):**
    Clopotul lui Gauss, definit de Medie ($\mu$) și Deviația Standard ($\sigma$).
    În contextul latenței, folosim o distribuție normală trunchiată (valori $\ge 0.1$ ms), deoarece timpul nu poate fi negativ. Este utilă pentru procese stabile, simetrice în jurul mediei.

*   **Indicatori Statistici:**
    *   **Media:** Centrul de greutate al distribuției.
    *   **Mediana:** Valoarea care împarte eșantionul în două jumătăți egale (robustă la valori extreme).
    *   **Modul:** Valoarea cea mai frecventă (vârful densității).

## 3. Reprezentări Grafice

Exercițiul include:
1.  **Graficul Densității de Probabilitate:**
    *   O histogramă a datelor simulate suprapusă cu curba teoretică a densității (PDF - Probability Density Function).
    *   Permite validarea vizuală a simulării (“cât de bine se potrivește modelul teoretic pe datele empirice”).

2.  **Statistici Descriptive:**
    *   Tabel comparativ între valorile empirice (calculate din date) și cele teoretice (din formule).

## 4. Pachete Software și Surse

### Pachete R utilizate:
*   `shiny`: Pentru interfața interactivă și reactivitate.
    *   *Funcționalitate cheie:* `moduleServer` pentru modularizare (izolarea logicii exercițiului), `eventReactive` pentru declanșarea simulării doar la apăsarea butonului.
*   `ggplot2`: Pentru vizualizare.
    *   *Funcționalitate cheie:* `geom_histogram` pentru datele empirice și `stat_function` pentru trasarea curbei teoretice exacte (`dgamma`, `dnorm`) peste histogramă.

### Surse de informație:
*   Documentația R pentru distribuții: `?rgamma`, `?rnorm`.
*   Teoria cozilor (Queueing Theory) pentru utilizarea distribuției Gamma în timpii de servire.

## 5. Codul și Comentarea Soluției

Soluția separă logica de simulare (`R/ex2_latenta.R`) de interfață (`Shiny/ex2_latenta_UI.R`).

### 5.1 Simularea Datelor

Funcția `simuleaza_latenta` generează eșantionul aleator. Se observă tratarea cazului Normal pentru a evita valori negative (folosind `pmax`).

```r
simuleaza_latenta <- function(n, tip, param1, param2) {
  if (tip == "Gamma") {
    # rgamma genereaza valori conform distributiei Gamma
    return(rgamma(n, shape = param1, rate = param2))
  } else {
    # rnorm genereaza valori normale
    val <- rnorm(n, mean = param1, sd = param2)
    # pmax(0.1, val) asigura ca nu avem timpi negativi sau zero
    return(pmax(0.1, val))
  }
}
```

### 5.2 Calculul Modului Empiric

Pentru distribuții continue, "modul" este vârful densității. Estimăm acest lucru folosind funcția `density` din R (Kernel Density Estimation).

```r
calculeaza_mod_empiric <- function(x) {
  d <- density(x)          # Calculeaza densitatea estimata
  return(d$x[which.max(d$y)]) # Returneaza x-ul corespunzator maximului y
}
```

### 5.3 Reactivitatea în Shiny

Folosim `req()` pentru a ne asigura că inputurile sunt valide înainte de a rula codul, prevenind erorile în UI.

```r
output$plot_latenta <- renderPlot({
  req(date_latenta(), input$p1, input$p2)
  # ... cod de plotare ...
})
```

## 6. Concluzii

1.  **Diferența Medie vs Mediană:** În cazul distribuției Gamma (asimetrice), media este trasă spre dreapta de valorile mari (coada lungă), în timp ce mediana rămâne un indicator mai bun al "cazului tipic".
2.  **Validarea Modelului:** Suprapunerea curbei teoretice peste histogramă confirmă corectitudinea generatorului de numere aleatoare.

