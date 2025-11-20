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
| ----------- | ----------------------------- |
| **Benigno** | Tumor no cancerígeno          |
| **Maligno** | Tumor cancerígeno (carcinoma) |


### Variables predictoras
Del dataset completo (10 variables × 3 versiones), se seleccionaron solo las variables que terminan en _mean, puesto que: representan el valor promedio por imagen, reducen multicolinealidad con las versiones _se y _worst, permiten modelos más estables, interpretables y comparables,

| Variable                   | Significado                                                                                      |
| -------------------------- | ------------------------------------------------------------------------------------------------ |
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
