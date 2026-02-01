# Analiză - Sinteză a Performanței Traficului și Impactului Economic

Această documentație sintetizează conceptele utilizate în cadrul proiectului, analizând modul în care simulările tehnice (trafic, latență, erori) se traduc în indicatori de performanță și rezultate economice. Analiza se bazează pe funcțiile și modulele implementate în exercițiile R.

## a) Rolul probabilității empirice

În cadrul proiectului, probabilitatea empirică servește ca metodă de validare și explorare a modelelor teoretice, în special acolo unde soluțiile analitice sunt complexe.

În acest proiect, probabilitatea empirică este obținută prin **Simulare Monte Carlo**, o tehnică ce folosește eșantionarea aleatoare repetată pentru a rezolva probleme deterministe sau probabilistice complexe.

* **Fundament Teoretic (Legea Numerelor Mari):**
    * Simulările noastre (ex: `n=100.000` în Ex3) se bazează pe **Legea Numerelor Mari (LLN)**. Aceasta garantează că, pe măsură ce numărul de experimente crește, media empirică (rezultatul simulării) converge către media teoretică (valoarea așteptată).
    * Astfel, probabilitatea empirică devine un estimator nedeplasat și consistent al probabilității reale.
* **Validare și Convergență:**
    * Funcțiile `trafic_simulat_poisson` (Ex1) și `simuleaza_latenta` (Ex2) generează date care, vizualizate prin histograme, validează distribuțiile teoretice.
* **Modelarea Sistemelor Complexe:**
    * Pentru scenarii unde calculul analitic este dificil (ex: probabilitatea de a avea succes după exact 2 retry-uri cu o latență totală < 300ms), metoda Monte Carlo (`simuleaza_evenimente`) oferă o soluție numerică rapidă și precisă, imposibil de obținut prin formule clasice simple.

*   **Validarea Modelelor:**
    *   Funcțiile de simulare precum `trafic_simulat_poisson` (Ex1) sau `simuleaza_latenta` (Ex2) generează seturi de date ("eșantioane") care sunt ulterior comparate cu valorile teoretice returnate de `trafic_teoretic_poisson` sau `statistici_teoretice_latenta`.
    *   Pragul de convergență dintre valorile empirice (calculate cu `mean`, `var`, `calculeaza_mod_empiric`) și cele teoretice confirmă corectitudinea implementării distribuțiilor (Poisson, Gamma, Normală).
*   **Simularea Scenariilor Complexe:**
    *   În `ex3_evenimente.R`, funcția `simuleaza_evenimente` permite estimarea probabilităților pentru scenarii compuse (de exemplu, succes după *k* reîncercări într-un timp total *T*), care sunt dificil de calculat euristic.
    *   Prin rularea unui număr mare de simulări (`n=100.000`), frecvența relativă a evenimentului devine o aproximare precisă a probabilității sale reale.

## b) Ce informații aduc condiționările

Analiza condiționată, implementată în `ex6_conditionate.R` prin funcția `calculeaza_conditionate`, dezvăluie dependențele ascunse dintre parametrii sistemului, oferind informații critice pentru diagnoză:

1.  **Eficiența Mecanismului de Retry ($P(A | N \le n_0)$):**
    *   Măsurând probabilitatea de Succes ($A$) condiționată de un număr mic de încercări ($N \le n_0$), putem determina dacă sistemul este eficient "din prima" sau dacă se bazează excesiv pe mecanismele de recuperare (retry).
2.  **Calitatea Serviciului ($P(B | A)$):**
    *   Probabilitatea ca timpul să fie bun ($B$) condiționat de faptul că cererea a avut succes ($A$) arată "costul" succesului. Un sistem poate avea o rată mare de succes, dar cu o latență inacceptabilă.
3.  **Discrepanța de Latență ($E[T | I=1]$ vs $E[T | I=0]$):**
    *   Compararea timpului mediu petrecut pentru cererile cu succes versus cele eșuate ajută la setarea timeout-urilor. Dacă $E[T | I=0]$ (timpul pierdut pentru un eșec) este foarte mare, înseamnă că sistemul așteaptă inutil înainte de a da eroare.

## c) Utilitatea inegalităților probabilistice

Verificate în `ex8_inegalitati.R` prin funcția `verificare_inegalitati`, aceste inegalități oferă garanții "worst-case" esențiale pentru definirea SLA-urilor (Service Level Agreements):

1.  **Inegalitatea lui Markov ($P(T \ge a) \le E[T]/a$):**
    *   Oferă o limită superioară pentru probabilitatea ca latența să depășească un prag critic. Este utilă pentru a garanta clienților că procentul de cereri foarte lente nu va depăși o anumită valoare, cunoscând doar media.
2.  **Inegalitatea lui Cebîșev ($P(|T - \mu| \ge k\sigma) \le 1/k^2$):**
    *   Măsoară stabilitatea sistemului. Dacă deviația standard ($\sigma$) este mare, Cebîșev ne avertizează că o proporție semnificativă din trafic va avea comportament imprevizibil (mult peste sau sub medie).
3.  **Inegalitatea lui Jensen ($E[T^2] \ge (E[T])^2$):**
    *   Este relevantă pentru funcțiile de cost neliniare. Dacă costul economic crește exponențial cu latența (funcție convexă), calcularea costului bazat doar pe latența medie va subestima costul real. Jensen arată că "costul mediu este mai mare decât costul mediei".

## d) Legătura dintre performanța tehnică și impactul economic

* **Agregarea și Teorema Limită Centrală (CLT):**
    * Un rezultat empiric crucial (demonstrat în Ex9) este că, deși latența individuală a unui client poate urma o distribuție asimetrică (Gamma), **latența totală agregată zilnic** tinde către o **Distribuție Normală**.
    * Această observație empirică simplifică enorm analiza de risc economic, permițându-ne să folosim media și deviația standard ($\mu, \sigma$) pentru a estima intervalele de încredere ale profitului.

Modulul `ex11_impact_economic.R` și funcția `simuleaza_business_case` demonstrează transformarea directă a parametrilor tehnici în rezultate financiare:

$$Profit = Venituri (Succes) - Pierderi (Churn) - Penalități (SLA)$$

*   **Rata de Succes ($p$) $\to$ Venit vs. Churn:** 
    *   O rată de succes mare crește direct veniturile. 
    *   Eșecurile nu înseamnă doar venit zero, ci generează **costuri de oportunitate (Churn)** (clienți pierduți definitive), care sunt adesea mult mai mari decât câștigul punctual per tranzacție (parametrul `eco_params$pierdere`).
*   **Latența ($\lambda, T$) $\to$ SLA:**
    *   Chiar dacă o cerere are succes ($I=1$), dacă timpul total $T$ depășește pragul `t_sla`, se aplică penalități. Astfel, performanța tehnică slabă (latență mare) erodează marja de profit chiar și în absența erorilor funcționale.

## e) Parametrii critici și îmbunătățirea sistemului

Pe baza analizei de sensibilitate a funcțiilor implementate, parametrii cu cel mai mare impact sunt:

1.  **Probabilitatea de Succes (`prob_succes`):**
    *   **Impact:** Este parametrul dominant. Scăderea sa cauzează pierderi masive prin Churn și anulează orice beneficiu de viteză.
    *   **Modificare:** Prioritizarea stabilității backend-ului înainte de optimizarea vitezei.

2.  **Deviația Standard a Latenței (`sd` în distribuții):**
    *   **Impact:** O medie bună cu o deviație mare duce la încălcări frecvente ale inegalităților lui Cebîșev și, implicit, la penalități SLA imprevizibile.
    *   **Modificare:** Implementarea de timeout-uri mai agresive (`nr_max_retry` optimizat) pentru a "tăia" coada distribuției ("long tail latency").

3.  **Pragul SLA (`t_sla`) vs. Latența Medie:**
    *   **Impact:** Dacă latența medie este prea aproape de `t_sla`, riscul de penalizare (Markov) crește exponențial.
    *   **Modificare:** Renegocierea SLA-ului tehnic sau scalarea resurselor pentru a reduce media latenței ($E[T]$) suficient de mult sub pragul $a$.

**Recomandare finală:**
Pentru maximizarea profitului, sistemul ar trebui modificat pentru a minimiza Churn-ul (prin creșterea robusteții `prob_succes`), chiar dacă acest lucru presupune inițial o latență medie ușor mai ridicată, atâta timp cât se menține în limitele de siguranță definite de inegalitățile probabilistice.
