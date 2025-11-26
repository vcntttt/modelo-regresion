# 🔥 1. ¿Qué son los **odds**?

Para un evento con probabilidad $p$, los **odds** (o razones de momios) se definen como:

$$
\text{odds} = \frac{p}{1-p}
$$

Interpretación:
- Si $p = 0.5$, los odds = 1 (igual de probable que ocurra que no ocurra).
- Si $p = 0.8$, los odds = 4 (4 veces más probable que ocurra).
- Si $p = 0.2$, los odds = 0.25 (4 veces más probable que NO ocurra).

Es una escala asimétrica:
- $p \in (0,1)$
- $odds \in (0, +\infty)$



# 🔥 2. ¿Qué es el **logit**?

El **logit** es el logaritmo natural de los odds:

$$
\text{logit}(p) = \log \left( \frac{p}{1-p} \right)
$$

¿Por qué usar logit?
- Transforma $p \in (0,1)$ a todo $\mathbb{R}$
- Permite modelar la probabilidad con una función **lineal** en los predictores:

$$
\log\left(\frac{p}{1-p}\right) = \beta_0 + \beta_1 X_1 + \cdots + \beta_k X_k
$$

Es decir:
- La regresión logística NO modela directamente $p$
- Modela el **logit de p** como una combinación lineal de X



# 🔥 3. ¿Qué es el **odds ratio (OR)**?

El OR mide **cuánto cambian los odds** cuando un predictor $X_j$ aumenta en una unidad.

En regresión logística:

$$
\text{OR}_j = e^{\beta_j}
$$

Interpretación:
- Si $\beta_j = 0.7$, entonces OR = $e^{0.7} \approx 2.01$
    - Los odds se multiplican por 2.01 cuando $X_j$ sube una unidad.
- Si OR = 1 → no hay efecto.
- Si OR > 1 → aumenta los odds.
- Si OR < 1 → disminuye los odds.

**Importante:**  
El OR no son probabilidades, es una razón de odds.



# 🔥 4. ¿Cuál es la **función objetivo** en la regresión logística?

La **función objetivo NO es el modelo** en sí.  
Son **dos cosas distintas**:

## ✔️ **El modelo**  
Es la ecuación que relaciona los covariables con el logit:

$$
\log\left( \frac{p}{1-p} \right) = X\beta
$$

O equivalente:

$$
p = \frac{1}{1 + e^{-X\beta}}
$$



## ✔️ **La función objetivo (objective function)**  
Es la función que el algoritmo optimiza para encontrar los $\beta$.

En regresión logística, la función objetivo es:

### 🎯 **Maximizar la verosimilitud**  
(= elegir los parámetros que hacen más probable observar los datos)

Para datos binarios $y_i \in \{0,1\}$:

$$
L(\beta) = \prod_{i=1}^{n} p_i^{y_i} (1-p_i)^{1-y_i}
$$

Y casi siempre trabajamos con la log-verosimilitud:

$$
\ell(\beta) = \sum_{i=1}^{n} \left[
y_i \log(p_i) + (1 - y_i)\log(1-p_i)
\right]
$$

**Esto es lo que realmente maximiza `glm()` en R o cualquier software.**



# 🔥 5. Resumen Conceptual Final

| Concepto | Qué es | Fórmula | Rol en regresión logística |
|---------|--------|----------|-----------------------------|
| **Odds** | Ratio "probabilidad vs no probabilidad" | $p/(1-p)$ | Representa la intensidad del evento |
| **Logit** | Logaritmo de los odds | $\log(p/(1-p))$ | Permite linealizar y usar regresión |
| **OR** | Impacto multiplicativo de un predictor en los odds | $e^{\beta_j}$ | Interpretación de efectos |
| **Modelo** | Ecuación que define cómo X influye en p | $\log(p/(1-p)) = X \beta$ | Describe la relación |
| **Función objetivo** | Lo que se optimiza para estimar los $\beta$ | maximizar $\ell(\beta)$ | Estima los parámetros |
