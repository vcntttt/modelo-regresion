# 🧬 Evaluación del ajuste en modelos de regresión logística  

Este apunte resume e interpreta tus propios resultados del análisis logístico del dataset WDBC, explicando **AIC**, **pseudo-R²** y su rol dentro de la bondad de ajuste. El documento está redactado en términos estadísticos (no de machine learning), orientado a interpretación y modelación.

# 1. ¿Qué es la bondad de ajuste en regresión logística?

La **bondad de ajuste** describe qué tan bien un modelo representa el comportamiento real de los datos.  
En regresión logística esto significa:

- ¿El modelo asigna altas probabilidades a casos malignos reales y bajas a benignos?
- ¿Mejora claramente respecto al modelo nulo (solo intercepto)?
- ¿Extrae información real de las variables morfológicas del tumor?

Como la variable respuesta es binaria, **no podemos usar R² clásico**.  
Por eso se utilizan dos familias de indicadores:

- **Pseudo-R²** → miden **bondad de ajuste** (calidad explicativa).
- **AIC** → mide **eficiencia del modelo** (interpretación + parsimonia), NO bondad de ajuste directa.

Tu profesor dijo algo clave:  
**AIC ayuda a elegir el mejor modelo para interpretación/explicación.  
Los pseudo-R² muestran la calidad predictiva del modelo dentro del marco estadístico.**

# 2. Resultados de los pseudo-R²: qué tan bien ajustan tus modelos

Los pseudo-R² se basan en log-verosimilitud: comparan cada modelo con el modelo nulo.

Valores altos indican **buena discriminación entre tumores benignos y malignos**.

### ✔ Modelo completo  
- **McFadden = 0.8055**  
- **Cox–Snell = 0.6549**  
- **Nagelkerke = 0.8933**

Interpretación:
- McFadden > 0.8 es extremadamente alto para regresión logística.  
- Esto indica **excelente ajuste**, comparable a un modelo muy informativo.  
- Nagelkerke ≈ 0.89 sugiere que el modelo capta casi toda la estructura separatoria del problema.

### ✔ Modelos reducidos (A, B, C, D)
- McFadden: 0.72–0.78  
- Nagelkerke: 0.84–0.88  

Interpretación:
- Todos los modelos tienen **buen ajuste**, pero **ninguno supera al modelo completo**.
- La caída del pseudo-R² en modelos B, C y D muestra una pérdida clara de poder explicativo.

### Conclusión sobre ajuste:

> **El modelo completo tiene la mejor bondad de ajuste.  
> Los modelos simplificados sacrifican capacidad explicativa.**

# 3. Interpretación del AIC: qué modelo conviene para análisis explicativo

El **AIC** penaliza complejidad: busca modelos **parcimoniosos**.

| Modelo | df | AIC |
|--------|----|------|
| **Completo** | 11 | **168.13** |
| Modelo A | 4 | 172.38 |
| Modelo B | 3 | 209.34 |
| Modelo C | 3 | 215.24 |
| Modelo D | 4 | 215.69 |

Interpretación:
- **El menor AIC es el del modelo completo (168.13)**.  
- Los modelos simples (B, C, D) pierden demasiada verosimilitud para justificar su reducción.  
- El Modelo A (3 variables) es competitivo, con un AIC solo ligeramente mayor.

Conclusión sobre AIC:

> **Para lograr el mejor balance entre ajuste y simplicidad, el Modelo A es una alternativa sólida si se prioriza la parsimonia.**

# 4. Relación entre pseudo-R² y AIC

### ✔ Pseudo-R² → se asocian a la **capacidad predictiva**  
Muestran qué tan bien el modelo logra separar benignos de malignos, comparado con el modelo nulo.

- Un McFadden de 0.80 indica **excelente poder predictivo**.
- Por eso se usan cuando el objetivo es evaluar calidad de clasificación o ajuste.

### ✔ AIC → se usa para **interpretación / selección de modelo**  
Ayuda a decidir qué combinación de predictores ofrece la mejor explicación estadística del fenómeno con la mínima complejidad posible.

- El modelo completo maximiza ese criterio.
- Pero el Modelo A logra un AIC cercano usando apenas tres predictores.

### Relación final:
> **Pseudo-R² evalúa qué tan bien se ajusta y predice.  
> AIC elige qué modelo es más eficiente para interpretar el fenómeno.**

# 5. Qué nos dicen los coeficientes del modelo completo

En el modelo completo, varias variables son significativas:

- **texture_mean (p < 0.001)**  
- **area_mean (p < 0.05)**  
- **smoothness_mean (p < 0.05)**  
- **concave.points_mean (p < 0.05)**  

Estas son las variables con evidencia estadística más fuerte de asociarse a malignidad.

Variables como perimeter_mean, compactness_mean o fractal_dimension_mean no alcanzan significancia individual, pero contribuyen colectivamente al alto poder explicativo del modelo completo.

# 6. Conclusión global (integrando pseudo-R² + AIC + coeficientes)

1. **El modelo completo es el que muestra mejor ajuste global** según los pseudo-R² y el AIC mínimo.  
2. **El Modelo A, aun siendo mucho más simple, conserva alrededor del 97% del poder explicativo del modelo completo.**  
3. El Modelo A usa solo tres variables altamente significativas, lo que lo hace más interpretable y estadísticamente eficiente.  
4. Los modelos B, C y D muestran pérdidas claras de ajuste y no son competitivos.  

### Conclusión final:

> **Aunque el modelo completo presenta el mejor ajuste en términos absolutos, el Modelo A se convierte en la elección más razonable cuando se prioriza la parsimonia.**  

> **Con apenas tres predictores, logra un rendimiento muy cercano al modelo completo, manteniendo todos sus coeficientes altamente significativos y ofreciendo una estructura más simple, interpretable y eficiente.**
