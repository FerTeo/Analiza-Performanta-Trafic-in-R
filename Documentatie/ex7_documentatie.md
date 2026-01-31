# Documentație Cerința 7: Analiza Dependenței

**Autor: Rachieru Gheorghe Gabriel

## 1. Descrierea Problemei

În modelele simplificate de analiză a traficului (ex. Exercițiul 3), presupunem adesea **independența** între încercările succesive. Adică, dacă prima cerere eșuează și facem un retry, a doua cerere are aceleași șanse de succes și aceeași distribuție a timpului de răspuns ca prima.

Acest model idealizat nu surprinde fenomenul de **congestie**. Într-un sistem real, dacă o cerere eșuează (timeout, server ocupat), este foarte probabil ca serverul să fie supraîncărcat. Prin urmare:
1.  Probabilitatea de succes la retry ar putea scădea.
2.  Timpul de răspuns (latența) la retry ar putea crește.

Exercițiul 7 modelează acest scenariu de **dependență**, unde eșecurile anterioare influențează negativ performanța încercărilor viitoare.

## 2. Modelul de Dependență (Penalizarea Latenței)

Am ales să modelăm dependența prin creșterea timpului mediu de răspuns după fiecare eșec.

### 2.1 Distribuția Exponențială Variabilă
Timpul de răspuns pentru o încercare ( $S_i$ ) urmează o distribuție exponențială $Exp(\lambda)$.
Media acestei distribuții este $E[S_i] = \frac{1}{\lambda}$.

În scenariul independent, $\lambda$ este constant ($\lambda_0$).
În scenariul dependent, introducem un **factor de penalizare** $f > 1$ (ex: $f=1.5$).
Dacă încercarea $k$ eșuează, rata pentru încercarea $k+1$ devine:

$$ \lambda_{k+1} = \frac{\lambda_k}{f} $$


Deoarece media este inversul ratei, rezultă că timpul mediu crește:

$$ E[S_{k+1}] = E[S_k] \times f $$


Aceasta simulează faptul că serverul răspunde din ce în ce mai greu pe măsură ce insistăm în timpul unei congestii.

## 3. Implementare

Codul sursă se află în `R/ex7_dependenta.R`.

Funcția `simuleaza_dependenta` reia logica de simulare Monte Carlo, dar cu parametrii dinamici:

```r
rata_exponentiala_curenta <- 1 / latenta_medie_initiala 

for (nr_retry in 0:nr_max_retry) {
    # Generare timp cu rata curentă
    timp_raspuns_curent <- rexp(1, rate = rata_exponentiala_curenta)
    
    # Decizie succes/eșec
    if (runif(1) <= prob_succes_per_try) {
        ... (Succes) ...
    } else {
        # La EȘEC, penalizăm rata pentru următoarea iterație
        rata_exponentiala_curenta <- rata_exponentiala_curenta / factor_penalizare_latenta
    }
}
```

## 4. Compararea Rezultatelor

Interfața Shiny (Tab-ul 7) permite vizualizarea grafică comparativă între modelul Independent și cel Dependent.

**Observații:**
1.  **Distribuția Timpului Total ( $T$ ):** În cazul dependent, coada distribuției ("tail") se lungește semnificativ spre dreapta. Apar timpi totali mult mai mari decât în cazul independent.
2.  **Impactul asupra SLA:** Probabilitatea de a respecta SLA-ul ( $P(T \le t_0)$ ) scade dramatic în scenariul dependent, chiar dacă probabilitatea de succes final ( $P(A)$ ) rămâne similară (dacă numărul de retry-uri e suficient).

Această analiză demonstrează importanța mecanismelor de "Backoff" (așteptare exponențială) în sistemele distribuite, dar și riscul ca aceste mecanisme să crească latența totală percepută de utilizator.
