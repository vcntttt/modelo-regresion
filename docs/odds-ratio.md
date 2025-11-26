# 📌 Regresión Logística: Odds, Logit, Odds Ratio, Función Objetivo y el Rol de Ridge/Lasso

Este documento resume de manera clara y técnica cómo funciona la regresión logística desde su formulación matemática hasta el impacto directo de las penalizaciones Ridge y Lasso en el modelo y en la estimación de los coeficientes.



# 🔥 1. ¿Qué son los *odds*?

Los **odds** son una forma alternativa de expresar una probabilidad.  
Mientras la probabilidad responde:  
> “¿Qué porcentaje de veces ocurre el evento?”  

los **odds** responden:  
> “¿Cuántas veces es más probable que ocurra el evento que que NO ocurra?”

Matemáticamente:

$$
\text{odds} = \frac{p}{1 - p}
$$

donde:

- $p$ = probabilidad de que ocurra el evento  
- $1 - p$ = probabilidad de que NO ocurra

### 🔍 Interpretación intuitiva

- **Odds = 1** → el evento es igual de probable que ocurra que no ocurra  
  (equivale a $p = 0.5$)

- **Odds > 1** → el evento es más probable que ocurra que no ocurra  
  (por ejemplo, si $\text{odds} = 4$, significa “4 veces más probable que ocurra”)

- **Odds < 1** → el evento es menos probable que ocurra  
  (por ejemplo, $\text{odds} = 0.25$ significa “4 veces más probable que NO ocurra”)

### 🔢 Ejemplos simples

| Probabilidad $p$ | Probabilidad de NO ocurrir $1-p$ | Odds = $p/(1-p)$ | Interpretación |
|------------------|-----------------------------------|------------------|----------------|
| 0.5 | 0.5 | 1 | Igual probabilidad |
| 0.8 | 0.2 | 4 | 4 veces más probable que ocurra |
| 0.2 | 0.8 | 0.25 | 4 veces más probable que NO ocurra |

### 🧩 Rango posible
- $p \in (0,1)$  
- $\text{odds} \in (0, +\infty)$  

En resumen:  
**Los odds comparan la probabilidad de que algo ocurra con la probabilidad de que no ocurra**, y esa proporción es la base del modelo logit en regresión logística.


# 🔥 2. ¿Qué es el *logit*?

El **logit** es el logaritmo natural de los odds:

$$
\text{logit}(p) = \log\left( \frac{p}{1-p} \right)
$$

Ventajas del logit:
- Convierte $p \in (0,1)$ en un valor real $(-\infty, +\infty)$.
- Permite modelar la probabilidad con una función **lineal** en los predictores:

$$
\log\left(\frac{p}{1-p}\right) = \beta_0 + \beta_1 X_1 + \cdots + \beta_k X_k.
$$

En resumen:
- La regresión logística **no modela la probabilidad directamente**, sino el **logit de $p$**.



# 🔥 3. ¿Qué es el *odds ratio (OR)*?

El **odds ratio** mide cuánto cambian los odds cuando un predictor $X_j$ aumenta en una unidad:

$$
\text{OR}_j = e^{\beta_j}
$$

Interpretación:
- Si $\beta_j = 0.7$:  
  $\text{OR} = e^{0.7} \approx 2.01$ → subir $X_j$ una unidad multiplica los odds por ~2.
- Si OR = 1 → sin efecto.  
- Si OR > 1 → aumenta odds.  
- Si OR < 1 → disminuye odds.

El OR **no es una probabilidad**, sino una razón de odds.



# 🔥 4. Modelo y Función Objetivo en Regresión Logística

## ✔️ Modelo (relación entre $X$ y la probabilidad)

$$
\log\left( \frac{p}{1-p} \right) = X\beta
$$

Equivalente:

$$
p = \frac{1}{1 + e^{-X\beta}}.
$$

Este es el **modelo logit**, que *no cambia* aunque se use regularización.



## ✔️ Función objetivo (lo que realmente optimiza el algoritmo)

La regresión logística estima los $\beta$ **maximizando la verosimilitud**:

$$
L(\beta) = \prod_{i=1}^{n} p_i^{y_i} (1-p_i)^{1-y_i}.
$$

Se usa casi siempre la **log-verosimilitud**:

$$
\ell(\beta) =
\sum_{i=1}^{n}
\left[
y_i \log(p_i) + (1 - y_i)\log(1-p_i)
\right].
$$

Este es el criterio interno de `glm()` en R.



# 🔥 5. Resumen Conceptual (versión tabla)

| Concepto | Definición | Fórmula | Rol |
|---------|------------|---------|-----|
| **Odds** | Razón $p$ vs $1-p$ | $p/(1-p)$ | Intensidad del evento |
| **Logit** | Logaritmo de odds | $\log(p/(1-p))$ | Linealiza el modelo |
| **Odds Ratio** | Cambio multiplicativo en odds | $e^{\beta_j}$ | Interpretación |
| **Modelo** | Relación $X \to p$ | $\log(p/(1-p)) = X\beta$ | Forma funcional |
| **Función objetivo** | Lo que se optimiza | $\max \ell(\beta)$ | Estimación |



# 🔥 6. Ridge & Lasso: Qué *sí* cambian y qué *no*

### ❌ Lo que **NO** cambian:
El modelo logit:

$$
\log\left( \frac{p}{1-p} \right) = X\beta.
$$

La forma de $p$:

$$
p = \frac{1}{1 + e^{-X\beta}}.
$$

### ✔️ Lo que **SÍ** cambian:
La **función objetivo usada para estimar los coeficientes**.



# 🔥 7. Función Objetivo con Regularización

La forma penalizada general es:

$$
\text{Objetivo} = -\ell(\beta) + \lambda \cdot Pen(\beta).
$$

$\lambda$ controla cuánto se penaliza la magnitud de los coeficientes.



# 🔥 8. Ridge (Penalización L2)

La penalización es la suma de cuadrados:

$$
Pen_{ridge}(\beta) = \sum_{j=1}^p \beta_j^2.
$$

Función objetivo:

$$
-\ell(\beta) + \lambda \sum_{j=1}^p \beta_j^2.
$$

### Efectos:
- Los coeficientes $\beta$ se **reducen en magnitud**.
- **Nunca llegan a cero**.
- Es excelente contra multicolinealidad.
- Hace el modelo más estable (menos varianza).

### Impacto en el logit:
$$
\log\left( \frac{p}{1-p} \right) = X\beta_{ridge}
$$

Con $\beta_{ridge}$ más pequeños:

$$
OR_j = e^{\beta_{j,ridge}} \approx 1.
$$



# 🔥 9. Lasso (Penalización L1)

Penalización como suma de valores absolutos:

$$
Pen_{lasso}(\beta) = \sum_{j=1}^p |\beta_j|.
$$

Función objetivo:

$$
-\ell(\beta) + \lambda \sum_{j=1}^p |\beta_j|.
$$

### Efectos:
- Algunos coeficientes quedan **exactamente en cero**.
- Realiza selección automática de variables.
- Reduce complejidad del modelo.

### Impacto en el logit:
$$
\log\left( \frac{p}{1-p} \right) = X\beta_{lasso}
$$

Si un coeficiente es 0:

$$
OR_j = e^0 = 1.
$$

La variable queda fuera del modelo.



# 🔥 10. Comparación Global

| Aspecto | Logística Estándar | Ridge | Lasso |
|--------|--------------------|--------|--------|
| Coeficientes | Sin restricción | Reducidos | Reducidos o = 0 |
| Selección variables | No | No | Sí |
| Estabilidad | Media | Alta | Alta |
| Multicolinealidad | No resuelve | Sí | Parcial |
| Interpretación | Completa | Similar pero con efectos reducidos | Más simple |



# 🔥 11. Resumen Final en 30 segundos

- El **modelo logit no cambia jamás**.  
- Lo que cambia es **cómo estimamos los coeficientes**.
- La función objetivo pasa de maximizar $\ell(\beta)$ a maximizar:

  - Ridge: $\ell(\beta) - \lambda \sum \beta_j^2$
  - Lasso: $\ell(\beta) - \lambda \sum |\beta_j|$

- Ridge encoge los coeficientes.  
- Lasso encoge *y elimina* coeficientes.  
- Los OR se acercan a 1 (o quedan en 1 si el coeficiente se hace cero).  
- La estabilidad del modelo mejora con regularización.


