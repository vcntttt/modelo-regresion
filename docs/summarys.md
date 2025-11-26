
Esta guía explica **cada parte** del resultado entregado por `glm()` cuando ajustas un modelo logístico con `family = binomial`.

```log
Call:
glm(formula = diagnosis ~ ., family = binomial, data = df)

Coefficients:
                        Estimate Std. Error z value Pr(>|z|)    
(Intercept)             -7.35952   12.85259  -0.573   0.5669    
radius_mean             -2.04930    3.71588  -0.551   0.5813    
texture_mean             0.38473    0.06454   5.961  2.5e-09 ***
perimeter_mean          -0.07151    0.50516  -0.142   0.8874    
area_mean                0.03980    0.01674   2.377   0.0174 *  
smoothness_mean         76.43227   31.95492   2.392   0.0168 *  
compactness_mean        -1.46242   20.34249  -0.072   0.9427    
concavity_mean           8.46870    8.12003   1.043   0.2970    
concave.points_mean     66.82176   28.52910   2.342   0.0192 *  
symmetry_mean           16.27824   10.63059   1.531   0.1257    
fractal_dimension_mean -68.33703   85.55666  -0.799   0.4244    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 751.44  on 568  degrees of freedom
Residual deviance: 146.13  on 558  degrees of freedom
AIC: 168.13

Number of Fisher Scoring iterations: 9
```


## 1. Llamada al modelo (Call)

```r
Call:
glm(formula = diagnosis ~ ., family = binomial, data = df)
```

### ¿Qué significa?

* **`diagnosis ~ .`** → la variable dependiente es `diagnosis`, y se usan **todas las demás variables** del dataset como predictores.
* **`family = binomial`** → es una **regresión logística** (logit).
* **`data = df`** → el dataset utilizado se llama `df`.


## 2. Tabla de coeficientes

```r
Coefficients | Estimate | Std. Error | z value | Pr(>|z|)
```

Cada fila es un predictor.
Cada columna significa:
| Columna           | Interpretación                                      |
|-------------------|-----------------------------------------------------|
| **Estimate**      | Coeficiente estimado β (efecto sobre el logit).     |
| **Std. Error**    | Error estándar del coeficiente.                     |
| **z value**       | Estadístico z = β / SE.                             |
| **Pr(>\|z\|)**      | p-value del test H₀: β = 0.                          |
| **Signif. codes** | Asteriscos indicando nivel de significancia.        |


### **Estimate ($\beta$)**  
Es el efecto del predictor sobre el **logit**:

$$
\log\left(\frac{p}{1-p}\right) = X\beta
$$

- $\beta > 0$ → aumenta la probabilidad del evento (diagnosis = maligno).  
- $\beta < 0$ → la disminuye.

Para interpretar en términos de *odds*, usamos:

$$
OR = e^{\beta}
$$

Ejemplo:  
`texture_mean = 0.38473`

$$
OR = e^{0.38473} = 1.47
$$

→ aumenta los *odds* en 47%.



### **Std. Error**

Mide la **incertidumbre** del coeficiente.

- SE pequeño → $\beta$ es confiable.  
- SE grande → hay ruido o inestabilidad numérica.

En este modelo, algunas variables tienen SE enormes (p. ej. fractal\_dimension\_mean), lo que indica:

- falta de escalamiento  
- multicolinealidad  
- predictores redundantes  



### **z value**

Es:

$$
z = \frac{\beta}{SE}
$$

Indica cuántas desviaciones estándar está el coeficiente lejos de 0.

- $|z|$ grande → fuerte evidencia contra $H_0$.  
- $|z|$ pequeño → la variable podría no importar.

Ejemplo:

`texture_mean`:

$$
z = \frac{0.38473}{0.06454} = 5.961
$$

→ muy significativo.



### **Pr(>|z|) = p-value**

Es la probabilidad de obtener un valor $z$ tan extremo **asumiendo que $H_0$ es verdadera**.

$$
H_0: \beta = 0
$$

Interpretación:

- p < 0.05 → el predictor aporta al modelo.  
- p ≥ 0.05 → no hay evidencia de efecto.

**Nota importante:**  
el p-value NO dice “la probabilidad de que H₀ sea verdadera”.  
Dice cuán extremo sería el estimate **si realmente $\beta = 0$**.



### **Signif. codes**

Son atajos visuales:

- `***` p < 0.001 → muy fuerte evidencia  
- `**` p < 0.01  
- `*` p < 0.05  
- `.` p < 0.1  
- vacío → no significativo


## 3. Variables significativas vs. no significativas

### Significativas (aportan al modelo)

* `texture_mean`
* `area_mean`
* `smoothness_mean`
* `concave.points_mean`

### No significativas (no aportan de forma independiente)

* `radius_mean`
* `perimeter_mean`
* `compactness_mean`
* `concavity_mean`
* `symmetry_mean`
* `fractal_dimension_mean`

Esto puede ocurrir por:

- Multicolinealidad (predictoras muy correlacionadas entre sí).  
- Redundancia en variables.  
- Efectos pequeños comparados con el ruido.  
- Falta de escala homogénea.  
- Estos predictores probablemente serían eliminados por **Lasso**.

### Problemas de escala numérica detectados

Coeficientes gigantes como 76.43 o -68.33 indican que el modelo usado con datos **sin estandarizar** es numéricamente inestable.

Esto afecta:

- estimates  
- std.errors  
- interpretabilidad  
- p-values  
- odds ratios

La recomendación profesional es **estandarizar todas las variables antes de usar una regresión logística multivariada**.



## 4. Parámetro de dispersión

```r
(Dispersion parameter for binomial family taken to be 1)
```

En regresión logística SIEMPRE es 1.
Nada que interpretar.


## 5. Deviance

```r
Null deviance: 751.44  on 568  degrees of freedom
Residual deviance: 146.13  on 558  degrees of freedom
```

### **Null deviance**

Error del modelo que NO usa predictores (solo la media).
Sirve como referencia.

### **Residual deviance**

Error del modelo con los predictores incluidos.

### Degrees of fredom

Los grados de libertad indican cuántos datos "libres" quedan para medir el error, después de descontar los parámetros que el modelo estima.

### Interpretación crucial

* Si la deviance disminuye muchísimo → el modelo **explica bien** la variable objetivo.
* Aquí la reducción es grande:

**751 → 146**

Esto indica un modelo **muy bueno**.


## 6. AIC

```r
AIC: 168.13
```

El **Akaike Information Criterion**:

* Penaliza por complejidad.
* **Más pequeño = mejor**, pero solo al comparar modelos.


## 7. Iteraciones del algoritmo

```r
Number of Fisher Scoring iterations: 9
```
* Número de pasos que necesitó el algoritmo para converger.
* Valores entre 4 y 15 son normales.


# 🔍 Resumen simplificado

* El modelo está bien ajustado y convergió sin problemas.
* La deviance baja muchísimo → **alto poder explicativo**.
* Solo algunas variables son realmente importantes estadísticamente.
* AIC=168 es bueno, pero útil solo comparado con otros modelos.
* Los coeficientes indican dirección e impacto sobre la probabilidad.
