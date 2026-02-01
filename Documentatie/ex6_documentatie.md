# Documentație Cerința 6: Probabilități Condiționate

**Autor: Rachieru Gheorghe Gabriel

## 1. Descrierea Problemei

Exercițiul 6 își propune să rafineze analiza performanței prin calcularea unor probabilități condiționate esențiale. Nu este suficient să știm probabilitatea generală de succes ($P(A)$) sau timpul mediu total ($E[T]$). Pentru o înțelegere mai profundă a sistemului, trebuie să răspundem la întrebări precum:

1.  **"Cât de probabil este succesul dacă am depus un efort mic?"** - Aceasta ne spune dacă succesul este corelat cu rezolvarea rapidă a cererii.
2.  **"Dacă avem succes, care este șansa să fi fost și rapizi?"** - Aceasta leagă fiabilitatea de calitatea serviciului (SLA).
3.  **"Cât așteaptă utilizatorul în medie când reușește vs când eșuează?"** - Această metrică diferențiată este critică pentru User Experience (UX). Un eșec rapid este adesea preferabil unui eșec lent ("fail-fast").

## 2. Aspecte Teoretice

### 2.1 Formula Probabilității Condiționate
Probabilitatea condiționată a evenimentului $A$ dat fiind $B$ se definește ca:

$$ P(A | B) = \frac{P(A \cap B)}{P(B)} $$

Unde $P(A \cap B)$ este probabilitatea ca ambele evenimente să aibă loc simultan.

### 2.2 Media Condiționată
Valoarea așteptată (media) a unei variabile aleatoare $T$, condiționată de producerea unui eveniment $A$, este:

$$ E[T | A] = \frac{E[T \cdot \mathbb{1}_A]}{P(A)} $$

*   Numărătorul $E[T \cdot \mathbb{1}_A]$ reprezintă media valorilor $T$ doar pentru cazurile unde $A$ s-a întâmplat (restul fiind considerate 0).
*   Numitorul $P(A)$ normalizează rezultatul la submulțimea cazurilor favorabile.

## 3. Implementare

Codul sursă se află în `R/ex6_conditionate.R`.

### 3.1 Calculul $P(A | N \le n_0)$
*   **Eveniment A:** Succes ($I=1$).
*   **Condiție $N \le n_0$:** Număr redus de reîncercări.
*   *Implementare R:*
    ```r
    # P(N <= n0)
    prob_Conditie_N <- mean(col_NrIncercari <= prag_retry_mic)
    # P(A si N <= n0)
    prob_Intersectie_A_N <- mean((col_Succes == 1) & (col_NrIncercari <= prag_retry_mic))
    # Rezultat
    prob_Succes_cond_RetryMic <- prob_Intersectie_A_N / prob_Conditie_N
    ```

### 3.2 Calculul $P(B | A)$
*   **Eveniment B:** Timp bun ($T \le t_0$).
*   **Condiție A:** Succes ($I=1$).
*   *Implementare R:* Calculăm proporția simulărilor care au avut ȘI timp bun ȘI succes, raportat la proporția totală de succese.

### 3.3 Calculul Mediilor Condiționate
*   **Timp Mediu Succes:** $E[T | I=1]$. Se calculează media timpilor `T` doar pentru rândurile unde `I=1`.
*   **Timp Mediu Eșec:** $E[T | I=0]$. Se calculează media timpilor `T` doar pentru rândurile unde `I=0`.


### 3.4 Rezultate Vizuale

![Rezultate Conditionate](/PozeDocumentatie/ex7_conditionari.png)

## 4. Concluzii și Interpretare
Rezultatele obținute în interfața Shiny (Tab-ul 6) ne permit să observăm corelații interesante:

- De obicei, $E[T | Esec] > E[T | Succes]$ într-un sistem cu retry-uri, deoarece eșecul final implică adesea epuizarea tuturor încercărilor disponibile (timp maxim pierdut).
- $P(B|A)$ ne arată procentul real de utilizatori mulțumiți dintre cei care au primit totuși serviciul.
