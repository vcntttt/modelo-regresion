# 📘 Verosimilitud y Log-Verosimilitud  
Apunte claro para comprender la base de la inferencia estadística


## 🧩 0. ¿Qué es un **parámetro**?

Un **parámetro** es un número desconocido que caracteriza a un modelo o distribución.

Ejemplos:
- Bernoulli/Binomial → **p** (probabilidad de éxito)  
- Normal → **μ** (media), **σ** (desviación estándar)  
- Poisson → **λ** (tasa)  
- Logística/GLM → **β₀, β₁, …** (coeficientes)

Los parámetros **no se observan directamente**: son propiedades del proceso que genera los datos.  
La estadística busca **estimarlos** usando una muestra.


## 🔍 1. ¿Qué es la **verosimilitud**?

La **verosimilitud** mide **qué tan plausible es un valor del parámetro** dado que ya observamos los datos.  
Es decir:

> No es “probabilidad del parámetro”, sino **probabilidad de los datos suponiendo un parámetro**.

Formalmente, si los datos son independientes:

$$
L(\theta) = \prod_{i=1}^n f(x_i \mid \theta)
$$

**Interpretación clave:**  
> Un parámetro es mejor que otro si produce datos más parecidos a los que realmente observamos.


## 🧠 1.1. ¿Qué estamos haciendo realmente?

- Los **datos ya están fijados** (lo observado no cambia).  
- El parámetro **no lo conocemos**.  
- Probamos distintos valores del parámetro y preguntamos:  
  **¿Qué tan coherente es este valor con los datos reales?**

La verosimilitud es justamente esa función de “coherencia”.


## 🎯 2. ¿Para qué se usa?

- **Estimación de parámetros** (Máxima Verosimilitud, MLE)  
  $$
  \hat{\theta} = \arg\max_\theta L(\theta)
  $$

- **Comparación entre modelos**  
  (AIC, BIC, test de razón de verosimilitudes)

- **Fundamento de los GLM**  
  (regresión logística, Poisson, binomial negativa, etc.)

- **Construcción de intervalos y pruebas estadísticas**  
  (devianza, test $G^2$, inferencia asintótica)


## 📌 3. Ejemplo claro

Supongamos datos Bernoulli:
```
1 0 1 1 1 0 (4 éxitos, 2 fracasos)
```

La verosimilitud como función de $p$ es:

$$
L(p)= p^4 (1-p)^2
$$

Buscamos el $p$ que hace más grande esta expresión:

$$
\hat{p} = \frac{4}{6}
$$

Ese es el **estimador por máxima verosimilitud**.


## 🔥 4. ¿Qué es la **log-verosimilitud**?

Es el **logaritmo natural** de la verosimilitud:

$$
\ell(\theta) = \log L(\theta)
$$

Convierte productos enormes en sumas manejables:

$$
\ell(\theta)= \sum_{i=1}^n \log f(x_i \mid \theta)
$$

Esto se usa siempre porque:
- evita problemas numéricos,
- simplifica derivadas,
- hace que la teoría asintótica funcione mejor.


## 🌟 5. ¿Por qué se usa tanto?

### ✔ Evita underflow numérico  
Multiplicar probabilidades pequeñas lleva a ceros computacionales.

### ✔ Simplifica derivadas  
Para maximizar, es mucho más fácil trabajar con $\ell(\theta)$ que con $L(\theta)$.

### ✔ Es base de criterios modernos  
AIC usa:

$$
AIC = -2\,\ell(\hat\theta) + 2k
$$

También fundamenta:
- la **devianza** en GLM,  
- el **test de razón de verosimilitudes**,  
- los **pseudo-R²**,  
- los intervalos basados en curvatura.

### ✔ Conecta con teoría estadística profunda  
La forma de $\ell(\theta)$ determina:
- la varianza del estimador,
- su aproximación normal,
- su eficiencia asintótica.


## 🧠 6. Resumen esencial (para recordar siempre)

- **Parámetro**: número desconocido que describe el modelo.  
- **Verosimilitud**: mide cuán compatibles son los datos con un parámetro.  
- **Log-verosimilitud**: logaritmo natural de $L(\theta)$; más estable y fácil.  
- **MLE**: el parámetro que maximiza la log-verosimilitud.  
- **Base de todo**: AIC, GLM, regresión logística, devianza, test LRT.

Si entiendes estos conceptos, la regresión logística, los GLM, el AIC y las pruebas de verosimilitud se vuelven muchísimo más intuitivos.

