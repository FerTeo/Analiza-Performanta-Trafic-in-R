# Documentație Cerința 11: Impact Economic și Analiză Cost-Beneficiu

## AUTOR : Bulacu Daria 

## 1. Descrierea Problemei

În ingineria sistemelor, performanța tehnică nu este un scop în sine, ci un mijloc de a atinge obiective economice. Această cerință face legătura între metricile tehnice (latență, rate de eroare, retry-uri) și indicatorii cheie de performanță (KPI) ai afacerii (profit, venituri, pierderi).

Problema constă în cuantificarea impactului financiar al calității serviciului (QoS). Un sistem instabil sau lent nu doar că nu generează venituri (din cauza erorilor), dar provoacă și pierderi directe (penalizări contractuale - SLA) și indirecte (pierderea clienților - Churn Rate). Scopul este simularea unui "Business Case" pe o perioadă de un an pentru a determina dacă arhitectura tehnică este sustenabilă economic.

## 2. Aspecte Teoretice

Modelarea economică se bazează pe concepte interdisciplinare, îmbinând ingineria traficului cu managementul riscului financiar:

*   **Service Level Agreement (SLA):**
    Un contract între furnizor și client care stipulează praguri de performanță garantate (de exemplu, un timp de răspuns sub 500ms). Încălcarea acestor praguri atrage penalități financiare automate, chiar dacă serviciul a fost livrat cu succes.

*   **Risc Operațional:**
    Definit ca riscul de pierdere rezultat din procese interne inadecvate sau eșuate, oameni și sisteme. În modelul nostru, acesta este cuantificat prin "Costul de Churn" (pierderea valorii viitoare a unui client nemulțumit) și costul erorilor tehnice.

*   **Funcția de Profit Zilnică:**
    Modelul matematic utilizat pentru calculul profitului ($P$) într-o zi $d$ este:
    $$ P_d = V_d - C_{churn,d} - C_{SLA,d} $$
    Unde:
    *   $V_d$: Veniturile din cereri procesate cu succes ($Succes \times Preț$).
    *   $C_{churn,d}$: Costul de oportunitate pentru clienții pierduți ($Eșec \times Cost_{Churn}$).
    *   $C_{SLA,d}$: Penalități pentru cereri reușite dar lente ($Succes \cap (Timp > T_{SLA}) \times Penalitate$).

## 3. Reprezentări Grafice

Analiza vizuală este crucială pentru a înțelege volatilitatea profitului:

1.  **Seria de Timp (Evoluția Profitului):**
    *   Un grafic liniar care arată fluctuația profitului zilnic pe parcursul anului.
    *   Permite identificarea sezonalității (ex: profituri mari vara, mici iarna) și a zilelor critice cu pierderi majore.
    *   Linia de zero demarchează clar zilele profitabile de cele cu pierderi.

2.  **Histograma Distribuției Profitului:**
    *   Arată frecvența anumitor nivele de profit. O distribuție asimetrică spre stânga (coadă lungă negativă) indică un risc mare de pierderi catastrofale, chiar dacă media este pozitivă.

## 4. Pachete Software și Surse de Inspirație

### Pachete R utilizate:
*   `dplyr`: Pentru agregarea datelor și calcule vectorizate.
*   `ggplot2`: Pentru vizualizarea seriilor de timp și a distribuțiilor.
*   `shiny`: Pentru simularea interactivă a scenariilor "What-If" (ex: "Ce se întâmplă dacă creștem prețul dar scade calitatea?").

### Surse de inspirație:
*   Modelele de cost din Cloud Computing (Amazon AWS, Azure SLA) au inspirat structura de penalizare.
*   Concepte din ingineria fiabilității (Reliability Engineering) pentru echilibrul cost-calitate.

## 5. Codul și Comentarea Soluției

Implementarea se bazează pe funcția `simuleaza_business_case` din `R/ex11_impact_economic.R`. Aceasta integrează generarea traficului (din Ex9) cu logica de evenimente (din Ex3) și aplică stratul economic.

### 5.1 Simularea Business Case-ului

```r
# simulare economica 
simuleaza_business_case <- function(nr_zile, lambda_mediu, 
                                    prob_succes, medie_latenta, nr_max_retry,
                                    eco_params) {
  
  
  trafic_zilnic <- genereaza_trafic_integrat(nr_zile, lambda_mediu)
  
  profituri <- numeric(nr_zile)
  venituri <- numeric(nr_zile)
  pierderi <- numeric(nr_zile)
  
  # iteram prin zile pentru analiza individuala a clientilor si efectul total asupra activitatii firmei 
  for (i in 1:nr_zile) {
    n_clienti <- trafic_zilnic[i]
    
    if (n_clienti > 0) {
      df_zi <- simuleaza_evenimente(n_clienti, prob_succes, medie_latenta, nr_max_retry)
      
      #definim functia de profit
      #veniturile calculate in urma cererilor cu succes 
      incasari_zi <- sum(df_zi$I == 1) * eco_params$castig
      
      #pierderile Churn (costul de oportunitate), in cazul clientilor care au renuntat exista pierderi 
      #de obicei este mai mare decat profitul 
      cost_churn_zi <- sum(df_zi$I == 0) * eco_params$pierdere
      
      #penalitatile SLA: Succes (I=1), Timp > t_sla pentru o plata de penalizare
      nr_penalitati <- sum(df_zi$I == 1 & df_zi$T > eco_params$t_sla)
      cost_sla_zi <- nr_penalitati * eco_params$penalitate
      
      #totalurile
      venituri[i] <- incasari_zi
      pierderi[i] <- cost_churn_zi + cost_sla_zi
      profituri[i] <- incasari_zi - cost_churn_zi - cost_sla_zi
      
    } else {
      profituri[i] <- 0
      venituri[i] <- 0
      pierderi[i] <- 0
    }
  }
  #istoricul financiar pe an pentru desenarea graficului
  return(data.frame(
    zi = 1:nr_zile,
    venit = venituri,
    pierdere = pierderi,
    profit = profituri
  ))
}
```

### 5.2 Calculul Statisticilor
Funcția `calculeaza_statistici_eco` sintetizează rezultatele într-un tablou de bord managerial.

```r
calculeaza_statistici_eco <- function(df_rezultate) {
  profit <- df_rezultate$profit
  
  list(
    medie_profit = mean(profit),
    deltiatie_profit = sd(profit),
    profit_total = sum(profit),
    zile_cu_pierdere = sum(profit < 0), 
    probabilitate_pierdere = mean(profit < 0) * 100
  )
}
```


## 6. Concluzii

Analiza economică evidențiază o concluzie critică pentru arhitecții de sistem: **fiabilitatea tehnică este direct proporțională cu profitabilitatea**.
1.  Chiar și o rată de eroare mică (1-2%) poate distruge profitul dacă costul de achiziție/pierdere a clientului (Churn Cost) este ridicat.
2.  Investiția în hardware pentru reducerea latenței este justificată economic doar dacă penalitățile SLA sunt semnificative.
3.  Vizualizarea riscului ajută la luarea deciziilor informate ("trade-off") între costul infrastructurii și calitatea serviciului oferit.

## 7. Bibliografie


**A. Surse Bibliografice (Cărți și Tratate)**

*   **Pentru Analiză Economică și Risc:**
    *   **Referință:** Hull, J. C. (2018). *Risk Management and Financial Institutions* (5th Edition). Wiley.
    *   **Utilizare:** Fundamentarea conceptelor de Risc Operațional și cuantificarea pierderilor financiare cauzate de erori tehnice. Cartea oferă cadrul pentru a trata erorile de sistem ca evenimente de risc operațional cuantificabile.

*   **Pentru Cloud Computing și SLA:**
    *   **Referință:** Buyya, R., et al. (2010). *Cloud Computing: Principles and Paradigms*. Wiley.
    *   **Utilizare:** Definirea parametrilor QoS (Quality of Service) și a structurilor de penalizare SLA (Service Level Agreement). Această lucrare a ghidat modul în care penalitățile de timp sunt aplicate în simulare.
