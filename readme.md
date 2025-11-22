# 🩺 Predicción de Cáncer de Mama — WDBC

El cáncer de mama representa uno de los principales desafíos de salud a nivel mundial, con más de 2 millones de diagnósticos nuevos al año. La detección temprana mejora drásticamente la supervivencia, y los modelos estadísticos pueden apoyar la clasificación temprana de tumores entre **benignos** y **malignos** usando mediciones tomadas de imágenes de biopsias.

El **Wisconsin Diagnostic Breast Cancer (WDBC)** es un dataset ampliamente utilizado en la literatura para desarrollar modelos de clasificación binaria basados en características geométrico-morfológicas del tumor.

Este estudio usa una versión depurada del dataset para comparar modelos logísticos construidos a partir de distintos **subconjuntos de variables**, con el objetivo de evaluar qué tan bien se puede clasificar el diagnóstico con menos información.



## 🎯 Pregunta de investigación

> **¿Podemos utilizar un subconjunto reducido de las características del tumor para predecir con alta precisión si un caso es benigno o maligno?**

Este trabajo busca determinar:

* si es posible obtener un modelo parsimonioso sin pérdida drástica de desempeño,
* qué grupos de variables aportan mayor poder predictivo,
* si un modelo compacto puede servir como herramienta explicativa,
* y cómo se comparan varios modelos reducidos frente al modelo completo.



## 🧪 Dataset

Se analiza el archivo:

**`breast_cancer_wisconsin_diagnostic.csv`**

Características relevantes:

* **569 observaciones**
* **30 variables predictoras** + **1 variable objetivo**
* Las variables corresponden a mediciones morfológicas derivadas de imágenes digitalizadas de biopsias
* La variable objetivo es:

  * `diagnosis`

    * B = “Benigno”
    * M = “Maligno”

Para facilitar el análisis y evitar redundancias, se consideran solo las variables que terminan en **`_mean`**, que representan el valor promedio de cada característica por imagen.
Este filtrado es una **decisión técnica** para limpiar el dataset y evitar multicolinealidad entre versiones `_mean`, `_se` y `_worst` de las mismas variables.



## 🧩 Variables del estudio
En este trabajo analizamos las características morfológicas extraídas de imágenes digitalizadas de biopsias de mama. Todas las variables predictoras provienen de mediciones computacionales realizadas sobre contornos, texturas y propiedades geométricas del tejido.

El objetivo es determinar si un subconjunto reducido de estas características permite predecir con precisión si un tumor es benigno o maligno.

### Variable objetivo (dependiente)

| Valor       | Significado                   |
| -- | -- |
| **Benigno** | Tumor no cancerígeno          |
| **Maligno** | Tumor cancerígeno (carcinoma) |


### Variables predictoras
Del dataset completo (10 variables × 3 versiones), se seleccionaron solo las variables que terminan en _mean, puesto que: representan el valor promedio por imagen, reducen multicolinealidad con las versiones _se y _worst, permiten modelos más estables, interpretables y comparables,

| Variable                   | Significado                                                                                      |
| -- |  |
| **radius_mean**            | Promedio de la distancia desde el centro del tumor hasta su perímetro (tamaño general).          |
| **texture_mean**           | Variación de niveles de gris en la imagen (relacionada con homogeneidad del tejido).             |
| **perimeter_mean**         | Longitud promedio del contorno del tumor.                                                        |
| **area_mean**              | Área promedio del tumor en la imagen.                                                            |
| **smoothness_mean**        | Variación local del radio; mide irregularidades a pequeña escala del contorno.                   |
| **compactness_mean**       | Relación entre perímetro y área; indica qué tan “compacto” o extendido es el tumor.              |
| **concavity_mean**         | Grado de concavidad del contorno (depresiones o curvas hacia adentro).                           |
| **concave.points_mean**    | Número y profundidad de puntos cóncavos en el tumor (muy discriminante entre benigno y maligno). |
| **symmetry_mean**          | Medida de simetría global del tumor.                                                             |
| **fractal_dimension_mean** | Complejidad geométrica del contorno (aproximación a un fractal).                                 |

## 🔬 Análisis de relaciones entre variables

Antes de construir los modelos logísticos, es fundamental estudiar las relaciones entre las variables predictoras para evitar problemas de **multicolinealidad** y **redundancia** que pueden afectar la estabilidad e interpretabilidad de los modelos.

### Técnicas de análisis aplicadas

El análisis se realizó mediante tres técnicas complementarias de visualización:

1. **Matrices de correlación**: Permiten cuantificar el grado de asociación lineal entre todas las variables numéricas.
2. **Gráficos de pares (GGpairs)**: Visualizan distribuciones, correlaciones y relaciones bivariadas de forma exhaustiva.
3. **Diagramas de ordenamiento (cpairs)**: Organizan las variables por similitud, facilitando la identificación de grupos redundantes.

Estos análisis revelaron patrones claros de agrupamiento que reflejan la naturaleza de las mediciones morfológicas del tumor.

### Identificación de clústeres de variables

A partir de la matriz de correlaciones, se identificaron **tres clústeres principales** que agrupan variables con alta redundancia interna:

### 🔵 1. Clúster de tamaño del tumor  
**Correlaciones > 0.95 entre sí**

- `radius_mean`  
- `perimeter_mean`  
- `area_mean`

Estas tres variables están matemáticamente relacionadas (área ≈ π × radio², perímetro ≈ 2π × radio) y describen esencialmente **la misma información: el tamaño del tumor**. 

Incluir las tres simultáneamente en un modelo produce **colinealidad perfecta**, lo que genera inestabilidad en los coeficientes estimados e inflación de varianzas.  

Basta con incluir **una sola** de ellas como representante del tamaño. Se prefiere `radius_mean` por su interpretación clínica directa.



### 🟣 2. Clúster de irregularidad del contorno  
**Correlaciones entre 0.85 - 0.95**

- `concavity_mean`  
- `concave.points_mean`  
- `compactness_mean`

Este grupo cuantifica **irregularidades morfológicas del borde tumoral**. Los tumores malignos tienden a presentar contornos más irregulares, con depresiones pronunciadas y forma menos compacta, características que estas tres variables capturan desde ángulos similares.

Aunque menos severa que en el clúster anterior, la alta correlación entre estas variables indica que aportan información parcialmente redundante.

Se selecciona `concave.points_mean` como variable representativa por su **alto poder discriminante** documentado en la literatura y por ser la menos correlacionada con otras variables fuera de este clúster.



### 🟡 3. Clúster de textura y propiedades geométricas finas  
**Correlaciones bajas con los clústeres anteriores (< 0.6)**

- `texture_mean`  
- `smoothness_mean`  
- `symmetry_mean`  
- `fractal_dimension_mean`

Estas variables capturan **aspectos complementarios** del tumor que no están relacionados con su tamaño o irregularidad del contorno. Describen homogeneidad del tejido (`texture_mean`), uniformidad local del borde (`smoothness_mean`), equilibrio geométrico (`symmetry_mean`) y complejidad estructural (`fractal_dimension_mean`).

Al presentar correlaciones bajas entre sí y con los otros clústeres, estas variables **aportan información independiente** y pueden combinarse con representantes de los otros grupos sin generar multicolinealidad significativa.

Se priorizan `texture_mean` y `symmetry_mean` por su interpretabilidad clínica y consistencia en estudios previos como variables complementarias de alto valor predictivo.



### ✔️ Implicaciones para el diseño de modelos

El análisis de correlaciones revela estructuras de redundancia que guían la construcción de modelos parsimoniosos y estables:

**Principios de selección de variables:**

1. **Evitar colinealidad severa:** No incluir múltiples variables del mismo clúster, especialmente del clúster de tamaño.
2. **Maximizar información complementaria:** Combinar variables de diferentes clústeres para capturar distintas dimensiones del problema.
3. **Priorizar poder predictivo documentado:** Seleccionar variables con evidencia empírica de discriminación entre benigno/maligno.
4. **Mantener interpretabilidad clínica:** Preferir variables con significado directo para el diagnóstico médico.

**Estrategia de modelado resultante:**

- ✅ **Una variable de tamaño**: `radius_mean` (clúster 1)
- ✅ **Una variable de irregularidad**: `concave.points_mean` (clúster 2)  
- ✅ **Una o dos variables complementarias**: `texture_mean` y/o `symmetry_mean` (clúster 3)

Esta estrategia garantiza modelos **estadísticamente estables**, **parsimoniosos** y **clínicamente interpretables**, formando la base para los modelos propuestos en la siguiente sección.



## 🧠 Modelos propuestos

Con base en el análisis de correlaciones y siguiendo los principios de parsimonia estadística, se proponen **cuatro modelos logísticos candidatos** que representan diferentes estrategias de simplificación del modelo completo.

Cada modelo busca responder a una pregunta específica sobre el **balance entre simplicidad y poder predictivo**:

> **¿Cuál es el conjunto mínimo de variables que mantiene un desempeño predictivo aceptable para la clasificación benigno/maligno?**

Los modelos se diseñaron estratégicamente para evaluar hipótesis específicas sobre qué información es verdaderamente necesaria.



### Modelo A — "Modelo completo parsimonioso"

**Hipótesis:** Un modelo con **tres variables**, una de cada clúster identificado, puede capturar la mayor parte de la información predictiva sin redundancia.

**Variables incluidas:**
- `radius_mean` → tamaño del tumor (clúster 1)
- `concave.points_mean` → irregularidad del contorno (clúster 2)
- `texture_mean` → heterogeneidad del tejido (clúster 3)

```r
modelo_A <- glm(
  diagnosis ~ radius_mean + concave.points_mean + texture_mean,
  data = df, family = binomial
)
```

Este modelo combina representantes de las tres dimensiones morfológicas principales sin incurrir en multicolinealidad. Se espera que tenga el **mejor balance entre parsimonia y capacidad predictiva**.



### Modelo B — "Modelo minimalista sin tamaño"

**Hipótesis:** El tamaño del tumor puede no ser estrictamente necesario si contamos con información sobre **irregularidad y textura**.

**Variables incluidas:**
- `concave.points_mean` → irregularidad del contorno (clúster 2)
- `texture_mean` → heterogeneidad del tejido (clúster 3)
```r
modelo_B <- glm(
  diagnosis ~ concave.points_mean + texture_mean,
  data = df, family = binomial
)
```

Este modelo **elimina la variable de tamaño** para evaluar si las características morfológicas finas son suficientes. Es el modelo más simple con información de dos clústeres distintos. Sirve para comprobar si el tamaño aporta poder predictivo significativo o si es redundante con las irregularidades del contorno.



### Modelo C — "Modelo morfológico fundamental"

**Hipótesis:** Las dos características más directamente relacionadas con malignidad (tamaño e irregularidad) bastan para una clasificación efectiva.

**Variables incluidas:**
- `radius_mean` → tamaño del tumor (clúster 1)
- `concave.points_mean` → irregularidad del contorno (clúster 2)
```r
modelo_C <- glm(
  diagnosis ~ radius_mean + concave.points_mean,
  data = df, family = binomial
)
```

Combina los dos predictores morfológicos más fuertes según la literatura clínica. Este modelo **prescinde de textura** para determinar si esta variable complementaria realmente mejora la predicción o si las dimensiones tamaño + irregularidad son suficientes.



### Modelo D — "Modelo con simetría"

**Hipótesis:** La **simetría del tumor** puede aportar información adicional valiosa cuando se combina con tamaño e irregularidad.

**Variables incluidas:**
- `radius_mean` → tamaño del tumor (clúster 1)
- `concave.points_mean` → irregularidad del contorno (clúster 2)
- `symmetry_mean` → equilibrio geométrico (clúster 3)

```r
modelo_D <- glm(
  diagnosis ~ radius_mean + concave.points_mean + symmetry_mean,
  data = df, family = binomial
)
```

Este modelo explora el uso de `symmetry_mean` en lugar de `texture_mean` como variable complementaria del clúster 3. Permite comparar **cuál de las dos variables de propiedades finas** (textura vs. simetría) aporta mayor valor predictivo en combinación con tamaño e irregularidad.



### Resumen comparativo de modelos
| Modelo | N° vars | Estrategia | Variables incluidas | Pregunta que responde |
|---|---:|---|---|---|
| **Modelo A** | 3 | Completo parsimonioso | tamaño + irregularidad + textura | ¿Es este el mejor balance parsimonia/predicción? |
| **Modelo B** | 2 | Sin tamaño | irregularidad + textura | ¿Es realmente necesario el tamaño del tumor? |
| **Modelo C** | 2 | Morfológico básico | tamaño + irregularidad | ¿Bastan las dos características más fuertes? |
| **Modelo D** | 3 | Con simetría | tamaño + irregularidad + simetría | ¿Simetría o textura es mejor complemento? |

Los cuatro modelos serán evaluados mediante AIC, pseudo-R², diagnósticos de residuos y matrices de confusión para determinar cuál ofrece el mejor desempeño práctico.

Resultados en `resultados.log`.
