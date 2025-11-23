## 1. **El modelo logístico nace de la Bernoulli**

Tu variable objetivo es:

$$
Y =
\begin{cases}
1 & \text{Maligno} \
0 & \text{Benigno}
\end{cases}
$$

Esto es EXACTAMENTE una **variable aleatoria Bernoulli**, con parámetro:

$$
p = P(Y=1 \mid X)
$$

Cada paciente tiene su propio valor de p según sus características (`radius`, `concave.points`, etc).



# 2. **Pero en tu dataset tienes MUCHAS Bernoulli → se comporta como Binomial**

Si tienes *n* observaciones independientes:

$$
Y_1, Y_2, \ldots, Y_n \sim \text{Bernoulli}(p_i)
$$

La suma:

$$
S = \sum_{i=1}^n Y_i
$$

tiene distribución **Binomial** con parámetros:

$$
S \sim \text{Binomial}(n, \bar{p})
$$

donde (\bar{p}) es una media ponderada de todas las probabilidades individuales.



## ⚠️ **IMPORTANTE DIFERENCIA (y por qué logística funciona)**

* En una binomial clásica todos los p_i son iguales → *p es constante*.
* En regresión logística **cada p_i DEPENDE de X_i**, porque:

$$
p_i = \frac{1}{1 + e^{-(\beta_0 + \beta_1x_{i1} + \dots + \beta_k x_{ik})}}
$$

En vez de una Binomial(n, p), tienes:

$$
Y_i \sim \text{Bernoulli}(p_i)\quad\text{con }p_i\text{ variable}
$$

Pero el **mecanismo de construcción de la verosimilitud** es exactamente el mismo que en la Binomial:

* producto de probabilidades de Bernoulli,
* logaritmo para convertirlo en suma.



# 3. **De Bernoulli a la función de verosimilitud (forma binomial)**

La probabilidad de un caso (Bernoulli) es:

$$
P(Y_i=y_i) = p_i^{y_i}(1-p_i)^{1-y_i}
$$

Si juntas todas las observaciones independientes:

$$
L(\beta)
= \prod_{i=1}^n p_i^{y_i}(1-p_i)^{1-y_i}
$$

💡 **Esta expresión es la misma estructura que la Binomial**, pero con p_i variables.

Luego tomamos logaritmo:

$$
\ell(\beta)
= \sum_{i=1}^n
\left[
y_i \log p_i + (1-y_i)\log(1-p_i)
\right]
$$

Este es el corazón del modelo logístico.
Todo el training consiste en encontrar los β que **maximizan esta función**.


# 4. **Cómo entra la logística: transformar p_i para que sea válido**

Sabiendo que p_i debe estar en [0,1], definimos:

$$
\log\left(\frac{p_i}{1-p_i}\right)=\beta_0+\beta_1x_{i1}+...+\beta_k x_{ik}
$$

y despejamos:

$$
p_i=\frac{1}{1 + e^{-z_i}}
\quad\text{donde } z_i=\beta'x_i
$$

Este p_i ahora puede entrar perfectamente en la verosimilitud binomial/bernoulli anterior.



# 5. **Interpretación de los parámetros**

### Cada β_j controla cómo cambia el *log-odds*:

$$
\beta_j > 0 \Rightarrow X_j\text{ aumenta } p_i
$$
$$
\beta_j < 0 \Rightarrow X_j\text{ disminuye } p_i
$$

El odds ratio:

$$
OR_j = e^{\beta_j}
$$

→ por cuánto se multiplican las probabilidades relativas de malignidad cuando X_j aumenta en 1 unidad.

Esto es lo que en medicina se interpreta como “riesgo relativo”.



# 6. **Por qué importa que sea Bernoulli/Binomial**

Sin este marco probabilístico:

* no podrías hablar de verosimilitud,
* no podrías usar AIC,
* no tendrías residuos deviance,
* no podrías testear significancia de coeficientes,
* no existiría el modelo logístico.

La regresión logística **no es un modelo geométrico**, es un modelo **probabilístico binomial generalizado**.

### La regresión logística es literalmente:

> Una Binomial con probabilidad variable
> p_i = logistic(β'x_i)



# 7. **Conexión con tu proyecto WDBC**

Tus 569 casos son 569 Bernoullis independientes:

* cada uno con su p_i modelado por tus 10 variables
* el conjunto se comporta como una binomial con p variable
* la verosimilitud que se maximiza es la suma de log-probabilidades bernoulli
* AIC compara verosimilitudes derivadas de esta binomial generalizada

Tu modelo A:

$$
\log\left(\frac{p}{1-p}\right) = \beta_0 +
\beta_1 , radius +
\beta_2 , concave.points +
\beta_3 , texture
$$

es matemáticamente una binomial con:

$$
p_i = \frac{1}{1+e^{-(\beta_0 + \beta_1 r_i + \beta_2 cp_i + \beta_3 t_i)}}
$$



# 8. **Por qué la logística funciona tan bien en cáncer de mama**

Porque la transición benigno → maligno **sigue una curva sigmoide natural**:

* tumores pequeños → probabilidad baja
* tumores medianos → transición rápida
* tumores grandes → probabilidad cercana a 1

Lo mismo para irregularidad del contorno.

Sigmoide = progresión rápida cuando una característica pasa cierto umbral.


# 9. **Resumen Final Clarísimo**

La matemática de tu modelo es:

1. Cada diagnóstico es una **Bernoulli(p_i)**.
2. El conjunto completo de datos es una **binomial con p variable**.
3. La probabilidad conjunta se expresa como:
   $$
   L(\beta)=\prod p_i^{y_i}(1-p_i)^{1-y_i}
   $$
4. Logaritmo → log-verosimilitud.
5. p_i se modela mediante la **función logística**, garantizando que está en [0,1].
6. β se estima maximizando la log-verosimilitud.
7. AIC penaliza modelos más grandes.
8. Odds ratio interpreta el efecto de cada variable.

Toda la regresión logística se explica con estas ideas.
