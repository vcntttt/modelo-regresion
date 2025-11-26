# 📘 Regularización en Regresión Logística: LASSO y Ridge  

Este documento presenta una explicación completa de las técnicas de regularización **LASSO** y **Ridge**, por qué es adecuado utilizarlas en el dataset WDBC, cómo funcionan matemáticamente, cómo se aplicaron en nuestro análisis y cómo interpretar los resultados obtenidos.  



# 1. ¿Qué es la regularización?

En modelos estadísticos, especialmente en regresión logística, es frecuente encontrarnos con:

- variables altamente correlacionadas (multicolinealidad),
- coeficientes inestables,
- sobreajuste (overfitting),
- modelos innecesariamente complejos.

La **regularización** introduce una penalización adicional en la función objetivo del modelo con el propósito de:

1. **Evitar sobreajuste**,  
2. **Estabilizar los coeficientes**,  
3. **Reducir complejidad**,  
4. **Mejorar la capacidad predictiva en datos nuevos**,  
5. **Seleccionar automáticamente variables relevantes** (solo LASSO).  

Existen dos métodos principales: **Ridge** y **LASSO**.



# 2. Regresión Ridge (Penalización L2)

## 2.1 ¿Qué es?

La regresión Ridge agrega una penalización proporcional a la **suma de los cuadrados** de los coeficientes:

$$
\lambda \sum_{j=1}^{p} \beta_j^2
$$

Esto es conocido como **penalización L2**.

## 2.2 ¿Qué hace Ridge?

- Reduce (“encoge”) los coeficientes hacia 0, pero **nunca los hace exactamente cero**.  
- Mantiene todas las variables y **reparte** el efecto entre predictores correlacionados.  
- Produce **coeficientes estables**, especialmente útil cuando existen clústeres de variables altamente correlacionadas.

## 2.3 ¿Cuándo es ideal usar Ridge?

- Cuando queremos mantener toda la información.  
- Cuando existe multicolinealidad extrema (como en WDBC).  
- Cuando la interpretabilidad no requiere eliminar predictores.  
- Cuando el objetivo es **estabilidad** y no selección de variables.



# 3. Regresión LASSO (Penalización L1)

## 3.1 ¿Qué es?

LASSO agrega una penalización proporcional a la **suma de valores absolutos** de los coeficientes:

$$
\lambda \sum_{j=1}^{p} |\beta_j|
$$

Esto es la **penalización L1**.

## 3.2 ¿Qué hace LASSO?

- Reduce coeficientes hacia cero.  
- Puede hacer que algunos coeficientes se vuelvan **exactamente cero**.  
- Realiza **selección automática de variables**.  
- Produce modelos **parsimoniosos y altamente interpretables**.

## 3.3 ¿Cuándo usar LASSO?

- Cuando queremos un modelo más simple.  
- Cuando hay variables redundantes.  
- Cuando la interpretabilidad es prioritaria.  
- Cuando se necesitan menos predictores sin perder desempeño.



# 4. ¿Por qué usar LASSO y Ridge en WDBC?

El dataset WDBC contiene:

- 10 variables `_mean`
- numerosos subgrupos altamente correlacionados:
  - tamaño: radius_mean, area_mean, perimeter_mean  
  - forma: concavity_mean, concave.points_mean, compactness_mean  
  - propiedades finas: texture_mean, smoothness_mean, symmetry_mean, fractal_dimension_mean

### Problemas generados por esta estructura:

- **Multicolinealidad severa** → coeficientes inflados e inestables.  
- **Redundancia** → varias variables describen lo mismo.  
- **Modelos sensibles a pequeñas perturbaciones**.

Por estas razones, aplicar regularización es completamente apropiado:

| Objetivo | LASSO | Ridge |
|---|:--:|:--:|
| Seleccionar predictores |  Sí |  No |
| Estabilizar coeficientes |  Moderado |  Excelente |
| Manejar colinealidad |  Depende |  Ideal |
| Obtener modelo compacto |  Alto |  No |



# 5. ¿Cómo funcionan Ridge y LASSO matemáticamente?

Partimos de la regresión logística clásica, cuya función a maximizar es la log-verosimilitud:

$$
\ell(\beta)
$$

Con regularización, maximizamos:

### **Ridge:**
$$
\ell(\beta) - \lambda \sum \beta_j^2
$$

### **LASSO:**
$$
\ell(\beta) - \lambda \sum |\beta_j|
$$

El parámetro **λ** controla cuánta penalización aplicamos.

- λ pequeño → modelo cercano al completo.  
- λ grande → coeficientes fuertemente penalizados.  
- En LASSO, λ grande → coeficientes EXACTAMENTE cero.

Los valores óptimos de λ se seleccionan automáticamente mediante **validación cruzada** (CV).



# 6. Cómo aplicamos LASSO y Ridge en WDBC

## 6.1 Preparación de datos

- Se seleccionaron solo variables `_mean` para evitar redundancia.  
- Se transformó diagnosis en 0/1.  
- Se creó una matriz numérica `X` y un vector `y`.  

## 6.2 Ajuste de modelos con `glmnet`

### **LASSO:**  
```r
cv_lasso <- cv.glmnet(X, y, family="binomial", alpha=1)
```

### **Ridge:**

```r
cv_ridge <- cv.glmnet(X, y, family="binomial", alpha=0)
```

En ambos casos se usaron:

* 10-fold cross-validation
* lambda.min (mejor error)
* lambda.1se (modelo más simple dentro de 1 desviación estándar)

## 6.3 Conversión a modelos `glm` clásicos

Para poder:

* obtener AIC,
* obtener pseudo-R²,
* comparar con modelos manuales,

reconstruimos modelos glm usando las variables seleccionadas por LASSO y Ridge.
## 7. Interpretación de los resultados obtenidos

### 7.1 Comparación de AIC

| Modelo | AIC | Comentario |
| --- | --- | --- |
| **LASSO (λ.min)** | **166.35** | Mejor ajuste (λ = 0.0063) |
| Modelo completo | 168.13 | Referencia sin penalización |
| Ridge (λ.min / λ.1se) | 168.13 | Replica el completo con coeficientes suavizados |
| **LASSO (1-SE)** | 172.35 | Compacto (λ = 0.0403) |
| Modelo A (manual) | 172.38 | 3 vars, muy interpretable |
| Modelos B–D | 209–215 | Pierden demasiada información |

### Interpretación

* **LASSO λ.min** ofrece el mejor desempeño global.
* **LASSO 1-SE** mantiene un AIC competitivo con menos variables.
* **Ridge** confirma el buen ajuste del modelo completo pero no reduce dimensionalidad.
* **Modelo A** se conserva como la opción manual más interpretable.


## 7.2 Selección de variables

### 🔵 LASSO (λ.min): 6 variables

`texture_mean`, `area_mean`, `smoothness_mean`, `concavity_mean`, `concave.points_mean`, `symmetry_mean`.
Mejor AIC, mantiene variables de forma y textura, descarta radio/perímetro.

### 🔵 LASSO (1-SE): 4 variables

`radius_mean`, `texture_mean`, `perimeter_mean`, `concave.points_mean`.
Modelo compacto dentro de 1-SE del mínimo de CV.

### 🔵 Ridge: 10 variables

Conserva todas las variables `_mean`; el aporte es estabilizar coeficientes ante colinealidad extrema.

## 7.3 Pseudo-R²

* Modelo completo y Ridge: McFadden R² ≈ **0.806**.
* LASSO λ.min: ≈ **0.797**.
* LASSO 1-SE: ≈ **0.784**.
* Modelo A: ≈ **0.781**.

### Interpretación:

* Ridge confirma que el modelo completo está bien ajustado pero sin selección de variables.
* LASSO mejora AIC con pérdida mínima de R².
* El modelo A sigue siendo eficiente y explicativo pese a su simplicidad.

## 7.4 Accuracy en datos de entrenamiento

Como complemento al AIC y a los pseudo‑R², se evaluó la **accuracy** (proporción de clasificaciones correctas) de todos los modelos sobre los mismos datos usados para el ajuste. Los resultados principales fueron:

- GLM completo: ≈ **0.949**
- Post‑LASSO (λ.min): ≈ **0.946**
- LASSO penalizado (λ.min): ≈ **0.944**
- Modelo A y post‑LASSO (λ.1se): ≈ **0.942**
- Ridge penalizado (λ.min): ≈ **0.940**

Modelos más simplificados (B, C, D y Ridge λ.1se) caen al rango **0.92–0.93**, lo que indica una ligera pérdida de desempeño al reducir demasiado la complejidad.  
Estos valores se obtuvieron con el script `lasso.r` y quedan registrados en `logs/05_accuracy_modelos.log`; al estar calculados en el conjunto de entrenamiento deben interpretarse como un límite superior del desempeño esperable en datos nuevos.



# 8. Conclusiones finales

## ✔ ¿Fue buena idea usar LASSO y Ridge?

Sí. Ambos métodos:

* mitigan la colinealidad severa,
* estabilizan coeficientes (Ridge),
* seleccionan variables (LASSO),
* permiten contrastar parsimonia vs. desempeño de forma automática.

## ✔ ¿Qué modelo es mejor?

Depende del objetivo:

### 🥇 **Mejor modelo predictivo global:**

**LASSO (λ.min)** — AIC ≈ 166.35

### 🎯 **Mejor modelo parsimonioso automático:**

**LASSO (1-SE)** — 4 variables, AIC competitivo

### 📘 **Mejor modelo manual interpretativo:**

**Modelo A** — 3 variables bien definidas

### ⚙️ **Modelo más estable:**

**Ridge** — equivalente al modelo completo, coeficientes suavizados

## ✔ ¿Qué aprendemos?

* LASSO identifica redundancias y simplifica el modelo.
* Ridge confirma la relevancia general de todas las variables.
* El dataset WDBC es muy informativo; incluso modelos simples son excelentes.
* Parsimonia y rendimiento no están peleados:

  * Modelo A
  * LASSO 1-SE
  * LASSO λ.min

representan puntos óptimos en el trade-off.
