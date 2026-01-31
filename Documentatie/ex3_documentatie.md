# Documentație Cerința 3: Cereri, Retry-uri și Evenimente

Autor: Donea Fernando-Emanuel


3. Cereri, retry-uri și evenimente
Definiți evenimentele:
    - 𝐴 = {𝐼 = 1} (succes);
    - 𝐵 = {𝑇 ≤ 𝑡0} (SLA);
    - 𝐶 = {𝑁 ≤ 𝑛0};
    - 𝐷 = {cel puțin un eșec}.

- a) Estimați empiric: 𝑃(𝐴), 𝑃(𝐵), 𝑃(𝐶), 𝑃(𝐴 ∩ 𝐵), 𝑃(𝐴 ∪ 𝐷)

- b) Verificați numeric formulele pentru reuniune/intersecție

- c) Explicați de ce probabilitatea empirică aproximează bine probabilitatea teoretică.

## 1. Descrierea Problemei

În analiza disponibilității și performanței serviciilor web, comportamentul unei cereri nu este binar (succes/eșec imediat). Adesea, sistemele implementează mecanisme de "Retry" (reîncercare) pentru a masca erorile tranzitorii. Această cerință își propune să analizeze probabilistic ciclul de viață al unei cereri într-un astfel de sistem.

Definim formal patru evenimente fundamentale care descriu starea sistemului:
*   **Evenimentul A (Succes Global):** Cererea este servită cu succes, fie din prima încercare, fie în urma unor reîncercări ($\{I = 1\}$).
*   **Evenimentul B (SLA Respectat):** Timpul total de răspuns ($T$) este mai mic decât o limită critică $t_0$ ($\{T \le t_0\}$). Acesta este un indicator de calitate a serviciului
*   **Evenimentul C (Efort Redus):** Numărul de reîncercări necesare ($N$) este sub un prag $n_0$ ($\{N \le n_0\}$)
*   **Evenimentul D (Instabilitate):** Apare **cel puțin un eșec** pe parcursul procesării ($\{N \ge 1\}$). Deși cererea poate reuși eventual (A), existența lui D indică probleme de infrastructură.

Scopul este de a estima probabilitățile acestor evenimente (și a intersecțiilor/reuniunilor lor) atât **empiric** (prin simulare Monte Carlo), cât și **teoretic** (folosind formule probabilistice exacte).

## 2. Aspecte Teoretice

Calculul probabilităților se bazează pe proprietățile variabilelor aleatoare geometrice (pentru numărul de încercări) și a sumelor de variabile exponențiale (distribuția Gamma, pentru timp).

Fie $p$ probabilitatea de succes a unei singure încercări și $q = 1-p$ probabilitatea de eșec.
Fie $k_{max}$ numărul maxim de reîncercări admise.

*   **Probabilitatea de Succes (A):**
    Este complementul evenimentului "toate cele $k_{max} + 1$ încercări eșuează".
    $$ P(A) = 1 - P(\text{toate eșuează}) = 1 - q^{k_{max}+1} $$

*   **Probabilitatea de Instabilitate (D):**
    D este echivalent cu faptul că prima încercare a eșuat.
    $$ P(D) = q $$

*   **Probabilitatea de a Respecta SLA (B):**
    Evenimentul B ($\{T \le t_0\}$) se poate realiza fie printr-un succes rapid, fie printr-un eșec rapid. Folosind Formula Probabilității Totale:
    $$ P(B) = P(A \cap B) + P(A^c \cap B) $$
    Unde $P(A^c \cap B)$ este probabilitatea de a eșua toate încercările, dar într-un timp mai scurt decât $t_0$ (ceea ce tehnic respectă SLA-ul de timp, deși cererea eșuează).
    $$ P(A^c \cap B) = q^{k_{max}+1} \times P(T_{fail} \le t_0) $$
    ($T_{fail}$ suma a $k_{max}+1$ latențe).

*   **Probabilitatea de Efort Redus (C):**
    Evenimentul C ($\{N \le n_0\}$) însumează probabilitățile ca procesul să se termine (cu succes sau eșec) în maxim $n_0$ reîncercări.
    $$ P(C) = \sum_{k=0}^{\min(n_0, k_{max})} P(N=k) $$
    Distribuția lui N este:
    - $P(N=k) = q^k p$ pentru $k < k_{max}$ (Succes la reîncercarea $k$)
    - $P(N=k_{max}) = q^{k_{max}}$ (Se atinge limita maximă de reîncercări)

*   **Intersecția A și B ($A \cap B$):**
    Reprezintă un succes obținut într-un timp util. Deoarece timpul total este suma timpilor încercărilor individuale (fiecare distribuit exponernțial $\sim Exp(\lambda)$), timpul după $k$ încercări urmează o distribuție Gamma $\sim \Gamma(k, \lambda)$.
    $$ P(A \cap B) = \sum_{k=1}^{k_{max}+1} P(\text{succes exact la încercarea } k) \times P(T_k \le t_0) $$
    Unde $P(T_k \le t_0)$ este funcția de repartiție a distribuției Gamma (în R: `pgamma`).

*   **Reuniunea A și D ($A \cup D$):**
    Probabilitatea ca cel puțin unul dintre evenimente să aibă loc se calculează folosind Principiul Includerii și Excluderii:
    $$ P(A \cup D) = P(A) + P(D) - P(A \cap D) $$
    Această formulă este esențială pentru a evita dubla contorizare a cazurilor comune (succes obținut după cel puțin un eșec).

## 3. Pachete Software

*   **Simulare:** `stats` (funcțiile `rexp` pentru generare exponențială, `runif` pentru decizie succes/eșec, `pgamma` pentru calcul teoretic).
*   **Interfață și Logică:** `shiny` pentru a permite modificarea dinamică a parametrilor ($p$, $t_0$, $n_0$) și recalcularea instantanee a probabilităților.

## 4. Codul și Comentarea Soluției

Soluția este implementată în fișierul `R/ex3_evenimente.R`.

### 4.1 Simularea Evenimentelor (Metoda Monte Carlo)

Funcția `simuleaza_evenimente` generează $N$ scenarii independente. În fiecare scenariu, simulăm procesul iterativ de retry:
1.  Se generează latența pentru încercarea curentă (`rexp`).
2.  Se decide succesul sau eșecul (`runif(1) <= prob_succes`).
3.  Dacă eșuează, se incrementează contorul și se reîncearcă (până la $k_{max}$).
4.  La final, se stochează statusul indicator ($I$), timpul total ($T$) și numărul de retry-uri ($N$).

### 4.2 Verificarea Numerică (Teoretic vs Empiric)

Pentru fiecare eveniment, comparăm frecvența relativă din simulare cu formula exactă.

**Exemplu calcul teoretic (din `calc_teoretic`):**
```r
# Probabilitatea evenimentului A (Succes Eventual)
prob_A <- 1 - q^(k_max + 1)

# Probabilitatea evenimentului D (Cel putin un esec)
prob_D <- q

# Intersectia A si B (Teorema Probabilitatii Totale)
# Sumam probabilitatea de a reusi exact la pasul i, inmultita cu probabilitatea ca timpul sa fie bun
prob_A_si_B <- 0
for (i in 1:(k_max + 1)) {
    prob_scenariu_succes <- q^(i - 1) * p
    # pgamma calculeaza probabilitatea ca suma a i variabile exponentiale sa fie <= t0
    prob_A_si_B <- prob_A_si_B + prob_scenariu_succes * pgamma(t0, shape = i, rate = lambda)
}
```

### 4.3 Validarea Relațiilor dintre Mulțimi

O cerință specifică este verificarea formulelor pentru reuniune și intersecție. Codul include verificări explicite în interfața Shiny:

**1. Verificarea Reuniunii ($A \cup D$):**
$$ P(A \cup D) = P(A) + P(D) - P(A \cap D) $$
În aplicație, această egalitate este confirmată numeric:
> = 0.9990 + 0.3000 - 0.2990
> = 1.0000

**2. Verificarea Intersecției ($A \cap B$):**
Folosind aceeași logică, verificăm consistența intersecției dedusă din reuniune:
$$ P(A \cap B) = P(A) + P(B) - P(A \cup B) $$
Acest lucru confirmă că estimatorii empirici respectă axiomele de probabilitate și că nu există discrepanțe logice în modul de calcul al evenimentelor compuse.

## 5. Concluzii

1.  **Convergența:** Rezultatele afișate în tabel arată erori absolute neglijabile (de ordinul $10^{-3}$ sau $10^{-4}$) între valorile simulate și cele teoretice. Aceasta validează implemetarea simulării și confirmă Legea Numerelor Mari.
2.  **Impactul Retry-urilor:** Analiza evenimentului $D$ vs $A$ ne arată că un sistem poate fi "fiabil" ($P(A) \approx 1$) chiar dacă este "instabil" ($P(D)$ mare), datorită mecanismului de retry. Totuși, acest lucru vine cu costul latenței (impact asupra $P(B)$).
3.  **Compromisul Performanță-Fiabilitate:** Creșterea numărului maxim de retry-uri ($k_{max}$) crește $P(A)$ (succesul), dar scade $P(B)$ (respectarea SLA) deoarece cererile reîncercate durează mai mult.

