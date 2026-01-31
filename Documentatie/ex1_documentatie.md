# Documentație Cerința 1: Modelarea Traficului Zilnic

Autor: Donea Fernando-Emanuel

Modelarea traficului zilnic (variabile aleatoare discrete)

- a) Modelați 𝐾𝑑 folosind, pe rȃnd, cel puțin două distribuții discrete (ex.: Poisson,
Binomială).

- b) Generați prin simulare eșantioane mari care să reprezinte traficul zilnic pentru o perioadă
de cȃțiva ani și reprezentați histogramele asociate acestora. Interpretați comparativ
histogramele obținute pe luni și pe ani.

- c) Estimați empiric media și varianța traficului pentru fiecare an și comparați cu valorile
teoretice.

- d) Interpretați diferențele între modele (trafic redus vs plafonat).

## 1. Descrierea Problemei

Această cerință vizează simularea și vizualizarea traficului zilnic de clienți într-un sistem comercial, reprezentând primul pas în analiza performanței. Într-un context real, sosirile clienților sunt fenomene influențate de factori precum capacitatea sistemului și perioada din an.

Scopul este de a construi un model flexibil care să permită comutarea între două tipuri fundamentale de distribuții (Poisson pentru trafic nelimitat și Binomial pentru trafic cu capacitate finită) și integrarea sezonalității. Analiza vizuală a acestor date simulate permite înțelegerea modului în care parametrii statistici și variațiile sezoniere influențează încărcarea sistemului pe termen lung și scurt.

## 2. Aspecte Teoretice

Modelarea se bazează pe următoarele concepte de probabilități:

*   **Procesul Poisson (Trafic "Natural"):**
    Folosit pentru a modela numărul de evenimente care apar într-un interval fix de timp, când aceste evenimente au loc cu o rată medie constantă ($\lambda$) și independent de timpul scurs de la ultimul eveniment.
    $$ P(X=k) = \frac{\lambda^k e^{-\lambda}}{k!} $$
    Este ideal pentru sisteme deschise cu un număr teoretic infinit de potențiali clienți.

*   **Distribuția Binomială (Trafic "Plafonat"):**
    Modelează numărul de succese în $n$ încercări independente, fiecare cu probabilitatea $p$.
    $$ P(X=k) = \binom{n}{k} p^k (1-p)^{n-k} $$
    Este adecvat pentru sisteme cu capacitate finită (ex: număr maxim de locuri, număr limitat de abonați), unde $n$ este limita superioară.

*   **Sezonalitatea**
    Introducerea variației în timp a parametrilor ($\lambda_t$ sau $n_t$). Traficul nu este uniform: el variază în funcție de anotimp, necesitând ajustarea parametrilor de bază cu factori multiplicativi (ex: $\lambda_{vara} = \lambda_{baza} \times 1.5$).

## 3. Reprezentări Grafice

Proiectul include vizualizări interactive esențiale pentru explorarea datelor:

1.  **Histograme Anuale:**
    *   Prezintă distribuția globală a numărului de clienți pentru fiecare an simulat.
    *   Permite verificarea stabilității macroscopice a sistemului pe termen lung.

2.  **Histograme Lunare:**
    *   O matrice de grafice care descompune traficul pe Ani și Luni.
    *   Utilizează coduri de culoare pentru anotimpuri (Iarna-Albastru, Vara-Portocaliu, etc.) pentru a evidenția vizual impactul sezonalității.
    *   Permite observarea rapidă a diferențelor de medie și dispersie între sezoane.

3.  **Vizualizare Detaliată:**
    *   Funcționalitate ce permite utilizatorului să dea click pe o lună specifică din situația globală pentru a o analiza în detaliu ("Zoom in").

## 4. Pachete Software și Surse de Inspirație

### Pachete R utilizate:
*   `shiny`: Pentru arhitectura aplicației web și logica reactivă (`reactive`, `observe`, `req`).
*   `ggplot2`: Pentru construirea declarativă a graficelor statistice.
*   `plotly`: Pentru a adăuga interactivitate graficelor `ggplot2` și pentru gestionarea evenimentelor de mouse (`event_data`, `event_register`).
*   `dplyr`: Pentru manipularea datelor (grupări, filtrări, sumare statistice).



## 5. Codul și Comentarea Soluției

Soluția este structurată pentru a separa logica probabilistică de interfața utilizator. Funcțiile de bază se află în `R/ex1_trafic.R` și implementează modelele matematice discutate.

### 5.1 Funcțiile de Simulare Probabilistică

Generarea eșantioanelor aleatoare se realizează prin două funcții dedicate, care folosesc funcțiile standard din R (`rpois`, `rbinom`). Acestea reprezintă realizarea empirică a variabilei aleatoare $K_d$ (numărul de clienți pe zi).

```r
trafic_simulat_poisson <- function(zile, lambda_val) {
  # genera un esantion de valori discrete cu rpois
  # lambda_val poate fi scalar sau vector (pentru sezonalitate)
  rpois(zile, lambda = lambda_val)
}

trafic_simulat_binomiala <- function(zile, n_val, p_val) {
  # modelam traficul cu plafon maxim(n) cu rbinom
  rbinom(zile, size = n_val, prob = p_val)
}
```

### 5.2 Funcțiile Teoretice

Pentru a compora propabilitatățile empirice,avem funcții care returnează proprietățile teoretice (momentele statistice) ale distribuțiilor utilizate. Aceste valori servesc drept valori teoretice pentru validarea simulării.

```r
trafic_teoretic_poisson <- function(lambda_val) {
  # La distributia Poisson, media = varianta = lambda
  return(list(m = lambda_val, v = lambda_val))
}

trafic_teoretic_binomiala <- function(n_val, p_val) {
  # La Binomiala: Media = n*p, Varianta = n*p*(1-p)
  medie <- n_val * p_val
  varianta <- n_val * p_val * (1 - p_val)
  return(list(m = medie, v = varianta))
}
```

### 5.3 Generarea Datelor și a Sezonalității ($K_d$)

Cea mai complexă parte a algoritmului este integrarea sezonalității. Rata medie de sosire nu este constantă, ci depinde de factorul sezonier $S_t$.

Algoritmul parcurge următorii pași:
1.  **Generarea axei temporale**: Se construiește un vector al lunilor și anotimpurilor pentru întreaga perioadă simulată (ani $\times$ 365 zile).
2.  **Aplicarea factorilor sezonieri**: Se asociază fiecărei zile un multiplicator bazat pe anotimp (Iarna: 0.8, Primăvara: 1.0, Vara: 1.5, Toamna: 1.1).
3.  **Ajustarea parametrilor**:
    *   Pentru **Poisson**: $\lambda_{zi} = \lambda_{input} \times factor_{sezon}$
    *   Pentru **Binomial**: $n_{zi} = round(n_{input} \times factor_{sezon})$

```r
#  Generare K_d cu parametri ajustati
K_d <- if (distributie == "Poisson") {
  # lambda variaza in functie de zi
  lambda_vec <- input_lambda * vec_factori
  # rpois accepta vector pentru lambda, generand un proces Poisson neomogen
  rpois(zile_totale, lambda = lambda_vec)
} else {
  # Capacitatea maxima (N) variaza in functie de zi
  n_vec <- round(input_n * vec_factori)
  rbinom(zile_totale, size = n_vec, prob = input_p)
}
```

### 5.4 Structura Datelor (Dataframe-ul)

Datele rezultate sunt organizate într-un `data.frame` numit date_trafic, necesar pentru vizualizarea ulterioară cu `ggplot2`. Fiecare rând reprezintă o observație unică (o zi).

| zile (index) | anul | luna | clienti ($K_d$) | 
| :--- | :--- | :--- | :--- |
| 1 | 1 | 1 (IAN) | 85 |
| ... | ... | ... | ... |
| 200 | 1 | 7 (IUL) | 145 |

Această structură permite gruparea ușoară după `anul` sau `luna` pentru calculul statisticilor agregate.

### 5.5 Generarea Histogramelor

Vizualizarea distribuțiilor de probabilitate simulate se realizează prin trei tipuri distincte de histograme.

#### A. Histogramele Anuale 
Prima vizualizare agregă datele la nivel de an. 

```r
output$plot_trafic_anual <- renderPlotly({
  # ...
  ggplot(date_trafic(), aes(x = clienti, ...)) +
    geom_histogram(fill = "skyblue", color = "black", bins = 30) +
    facet_wrap(~anul) + # Un grafic separat pentru fiecare an
    labs(title = "Distributia Traficului pe Ani")
})
```
Din punct de vedere probabilistic, ne așteptăm ca forma acestor histograme să fie aproape identică de la un an la altul (datorită legii numerelor mari).

#### B. Histogramele Lunare 
Această vizualizare descompune distribuția anuală în componentele sale lunare.

```r
# Vizualizare matriciala: Ani x Luni
ggplot(dt, aes(x = clienti, fill = anotimp)) +
  geom_histogram(color = NA, bins = 15) +
  facet_grid(anul ~ luna_nume) + # Grila bidimensionala
  scale_fill_manual(...) # Culori specifice fiecarui anotimp
```
Aceasta este vizualizare permite validarea modelului sezonier. Se poate observa vizual cum media distribuției  se deplasează spre dreapta în lunile de vară (trafic intens) și spre stânga iarna.

#### C. Histograma Detaliată (Analiza Distribuției Locale)
Prin mecanismul de interactivitate, utilizatorul poate izola o singură lună. Aceasta permite inspecția detaliată a funcției de masă de probabilitate pentru, de exemplu, "Luna Iulie, Anul 2".

```r
# Se activeaza doar la click pe o celula din grid-ul de mai sus
df_filtrat <- dt %>% filter(anul == sel_an, luna == sel_luna)

ggplot(df_filtrat, aes(x = clienti, fill = anotimp)) +
  geom_histogram(color = "black", bins = 30) +
  labs(title = paste("Distributia Traficului - Anul", sel_an, "Luna", sel_luna))
```




## 6. Concluzii

1.  Simularea demonstrează că alegerea distribuției (Poisson vs Binomial) influențează fundamental dispersia datelor: modelul Binomial prezintă sub-dispersie (varianța < media) datorită plafonării capacității.
2.  Integrarea sezonalității este crucială pentru realism; mediile globale ascund variații locale masive care pot pune presiune pe sistem în perioadele de vârf (Vara).


