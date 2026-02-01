# Documentație Cerința 8: Inegalități Probabilistice

**Autor: Rachieru Gheorghe Gabriel

## 1. Descrierea Problemei

În proiectarea sistemelor fiabile, nu cunoaștem întotdeauna distribuția exactă a timpilor de răspuns sau a erorilor. Totuși, avem nevoie de garanții "worst-case". Teoria probabilităților oferă un set de inegalități clasice care pun limite asupra comportamentului variabilelor aleatoare, cunoscând doar media și varianța.

Exercițiul 8 verifică validitatea acestor limite teoretice pe datele noastre simulate. Scopul este dublu:
1.  Validarea corectitudinii simulării (dacă datele ar încălca o teoremă matematică, simularea ar fi greșită).
2.  Înțelegerea utilității acestor limite pentru estimări rapide ("Back-of-the-envelope calculations").

## 2. Inegalități Verificate

### 2.1 Inegalitatea lui Markov
Aceasta oferă o limită superioară pentru probabilitatea ca o variabilă aleatoare nenegativă să depășească o anumită valoare.

**Enunț:** Pentru orice variabilă aleatoare $X \ge 0$ și orice constantă $a > 0$:

$$ P(X \ge a) \le \frac{E[X]}{a} $$


**În contextul nostru:**
Probabilitatea ca timpul total $T$ să depășească un prag critic $a$ este cel mult media timpului împărțită la $a$.


<img src="/PozeDocumentatie/ex8_markov.png" width="500" alt="Markov">



### 2.2 Inegalitatea lui Cebîșev (Chebyshev)
Aceasta limitează probabilitatea ca o variabilă să devieze mult de la media sa, indiferent de distribuție.

**Enunț:** Fie $\mu = E[X]$ și $\sigma^2 = Var(X)$. Pentru orice $k > 0$:

$$ P(|X - \mu| \ge k\sigma) \le \frac{1}{k^2} $$


**În contextul nostru:**
Spune că timpii de răspuns "extremi" (foarte mici sau foarte mari față de medie) sunt rari. De exemplu, cel mult $1/4$ (25%) din cereri pot avea timpi deviați cu mai mult de $2\sigma$ față de medie.


<img src="/PozeDocumentatie/ex8_cebisev.png" width="500" alt="Cebisev">



### 2.3 Inegalitatea lui Jensen
Aceasta relaționează valoarea funcției aplicată mediei cu media funcției aplicate variabilei, pentru funcții convexe.

**Enunț:** Dacă $\varphi$ este o funcție convexă, atunci:

$$ \varphi(E[X]) \le E[\varphi(X)] $$


**În contextul nostru:**
Am ales funcția convexă $\varphi(x) = x^2$. Inegalitatea devine:

$$ (E[T])^2 \le E[T^2] $$

Aceasta este, de fapt, echivalentă cu proprietatea că varianța este nenegativă ($Var(T) = E[T^2] - (E[T])^2 \ge 0$).


<img src="/PozeDocumentatie/ex8_jensen.png" width="500" alt="Jensen">



## 3. Implementare și Verificare

Codul sursă se află în `R/ex8_inegalitati.R`.

Funcția `verificare_inegalitati`:
1.  Preia vectorul de timpi simulați $T$.
2.  Calculează statisticile descriptive: Media ($E[T]$), Deviația Standard ($SD[T]$).
3.  Pentru fiecare inegalitate, calculează separat:
    *   **Partea stângă (Empirică):** Numără cazurile din simulare care satisfac condiția (ex: proporția valorilor $\ge a$).
    *   **Partea dreaptă (Teoretică):** Aplică formula limitei (ex: $E[T]/a$).
4.  Compară cele două valori și returnează `TRUE` dacă inegalitatea este respectată.

## 4. Concluzii

Rularea verificărilor în Shiny (Tab-ul 8) confirmă că **toate inegalitățile sunt respectate** pe seturile de date simulate.

Acest lucru validează robustețea generatorului nostru de numere aleatoare și corectitudinea implementării logice. De asemenea, arată că limitele teoretice (deși adesea "slabe" sau conservatoare) sunt întotdeauna valabile și pot fi folosite pentru a dimensiona sistemul în lipsa unor date precise de distribuție.
