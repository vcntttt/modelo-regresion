# 7. ¿Cómo se calcula matemáticamente el AIC?

El **Akaike Information Criterion (AIC)** se basa en la log-verosimilitud máxima del modelo y en el número de parámetros estimados.

Su fórmula es:

$$
AIC = -2 \log(\hat{L}) + 2k
$$

donde:

- $\hat{L}$ es el **valor máximo de la verosimilitud** del modelo.
- $k$ es el **número de parámetros** estimados (incluyendo el intercepto).

Interpretación matemática:
- El término $-2\log(\hat{L})$ mide qué tan bien el modelo explica los datos.
- El término $2k$ penaliza la complejidad del modelo.
- Menor AIC = mejor equilibrio entre ajustar bien y usar pocos parámetros.

En regresión logística, la log-verosimilitud se calcula como:

$$
\log(L) = \sum_{i=1}^n \Big[ y_i \log(p_i) + (1 - y_i)\log(1 - p_i) \Big]
$$

donde:
- $p_i$ es la probabilidad predicha por el modelo para la observación $i$.
- $y_i \in \{0,1\}$ es la etiqueta real.

El AIC no requiere predicciones clasificadas (0/1), solo las probabilidades del modelo.


# 8. ¿Cómo se calculan matemáticamente los pseudo-R²?

Los pseudo-R² derivan de comparar la log-verosimilitud del modelo completo con la del modelo nulo.

El **modelo nulo** contiene solo el intercepto y representa el peor caso:  
“todos los tumores tienen igual probabilidad de ser malignos”.

## 8.1 McFadden R²

Es el pseudo-R² más utilizado en regresión logística:

$$
R^2_{\text{McFadden}} = 1 - \frac{\log L_{\text{modelo}}}{\log L_{\text{nulo}}}
$$

Interpretación matemática:
- Si el modelo completo mejora mucho la log-verosimilitud respecto al nulo, el cociente se hace pequeño y el R² sube.
- Rango típico en logística: 0.2–0.4 (tu modelo completo llega a 0.80, extraordinario).

## 8.2 Cox–Snell R²

Se basa en la razón de verosimilitudes elevadas a una corrección por tamaño muestral:

$$
R^2_{CS} = 1 - \left(\frac{L_{\text{nulo}}}{L_{\text{modelo}}}\right)^{2/n}
$$

Problema:  
**nunca puede alcanzar 1**, aun con un modelo perfecto.

## 8.3 Nagelkerke R²

Normaliza Cox–Snell para que su máximo sea 1:

$$
R^2_{N} = \frac{R^2_{CS}}{1 - L_{\text{nulo}}^{2/n}}
$$

Es el pseudo-R² más interpretativo cuando se quiere un valor “tipo R²” entre 0 y 1.

