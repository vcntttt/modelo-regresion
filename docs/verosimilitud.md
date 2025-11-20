# 📘 Verosimilitud y Log-Verosimilitud  

## 🔍 1. ¿Qué es la **verosimilitud**?

La **verosimilitud** mide **qué tan plausible es un valor del parámetro** dado que ya observamos los datos.  
No es “probabilidad del parámetro”, sino **probabilidad de los datos suponiendo un parámetro**.

Si los datos son independientes:

$$
L(\theta) = \prod_{i=1}^n f(x_i \mid \theta)
$$

**Idea clave:**  
> Un mejor modelo (o parámetro) es aquel que hace más probable haber observado los datos que tenemos.


## 🎯 2. ¿Para qué se usa?

- **Estimación de parámetros** (Máxima Verosimilitud, MLE)  
  $$
  \hat{\theta} = \arg\max_\theta L(\theta)
  $$

- **Comparación entre modelos** (AIC, BIC, LRT)

- **Fundamento de los GLM** (logística, Poisson, etc.)

- **Construcción de intervalos y pruebas estadísticas**  
  (test de razón de verosimilitudes, devianza)


## 📌 3. Ejemplo

Datos Bernoulli:
```
1 0 1 1 1 0 (4 éxitos, 2 fracasos)
```


$$
L(p)= p^4 (1-p)^2
$$

El parámetro que maximiza esta expresión es:

$$
\hat{p} = \frac{4}{6}
$$


## 🔥 4. ¿Qué es la **log-verosimilitud**?

Simplemente:

$$
\ell(\theta) = \log L(\theta)
$$

Convierte productos enormes en sumas manejables:

$$
\ell(\theta)= \sum_{i=1}^n \log f(x_i \mid \theta)
$$


## 🌟 5. ¿Por qué se usa tanto?

### ✔ Evita underflow numérico  
Probabilidades muy pequeñas multiplicadas → 0 para un computador.

### ✔ Simplifica derivadas  
Para maximizar, derivamos $\ell(\theta)$, no $L(\theta)$.

### ✔ Permite pruebas y criterios modernos  
- AIC usa:  
  $$
  AIC = -2\,\ell(\hat\theta) + 2k
  $$
- Devianza en GLM  
- Test de razón de verosimilitudes (LRT)

### ✔ Da propiedades asintóticas importantes  
La forma de $\ell(\theta)$ determina la precisión del estimador.


## 🧠 6. Resumen esencial (para recordar siempre)

- **Verosimilitud:** compatibilidad entre datos y parámetros.  
- **Log-verosimilitud:** logaritmo de la verosimilitud → más estable y fácil.  
- **MLE:** parámetro que maximiza la log-verosimilitud.  
- **Base de todo:** AIC, GLM, logistic regression, devianza, LRT.

Si entiendes estos conceptos, gran parte de la estadística inferencial moderna se vuelve mucho más intuitiva.



