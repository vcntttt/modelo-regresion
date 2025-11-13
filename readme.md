# 🩺 Diabetes Risk Prediction — BRFSS 2015

La diabetes es una de las enfermedades crónicas más prevalentes en Estados Unidos, afectando a más de 34 millones de personas y representando costos superiores a los $300 mil millones de dólares al año. La detección temprana es esencial para prevenir complicaciones graves como enfermedades cardíacas, insuficiencia renal, ceguera o amputaciones.

El **Behavioral Risk Factor Surveillance System (BRFSS)** es la encuesta telefónica anual más grande del mundo sobre factores de riesgo en salud, realizada por el **CDC (Centers for Disease Control and Prevention)** desde 1984. Este proyecto utiliza una versión limpia del BRFSS 2015 para evaluar factores asociados a la diabetes y explorar modelos predictivos de riesgo.


## 🎯 Pregunta de investigación
<!-- > **Can we use a subset of the risk factors to accurately predict whether an individual has diabetes?** -->

> **¿Podemos usar un subconjunto de los factores de riesgo para predecir con precisión si un individuo tiene diabetes?**

Este estudio busca determinar:
- si es posible predecir la presencia de diabetes usando solo algunas variables del BRFSS,
- qué factores aportan mayor poder predictivo,
- si un modelo reducido puede servir como herramienta de tamizaje poblacional.


## 🧪 Dataset
Se utiliza la versión:
**`diabetes_binary_5050split_health_indicators_BRFSS2015.csv`**

Características principales:
- **70.692 personas encuestadas**
- **Dataset balanceado** 50% sin diabetes, 50% con prediabetes o diabetes  
- **Variable objetivo:**  
  - `Diabetes_binary`  
    - 0 = no diabetes  
    - 1 = prediabetes o diabetes  
- **21 variables predictoras** relacionadas a salud física, estilo de vida, actividad, IMC, edad, entre otros.

Este dataset es especialmente adecuado para modelos de clasificación binaria al evitar problemas de desbalance en la variable objetivo.

## 🔍 Variables del estudio

### 🎯 Variable objetivo (dependiente)
**Diabetes_binary**  
- 0 = No diabetes  
- 1 = Prediabetes o diabetes  
Esta es la variable que buscamos predecir utilizando un subconjunto de factores de riesgo.

---

### 🧩 Variables predictoras

| Variable | Significado |
|---------|-------------|
| **HighBP** | Diagnóstico de hipertensión arterial (1 = sí, 0 = no). |
| **HighChol** | Diagnóstico de colesterol alto (1 = sí, 0 = no). |
| **CholCheck** | Chequeo de colesterol en los últimos 5 años (1 = sí, 0 = no). |
| **BMI** | Índice de masa corporal (kg/m²). |
| **Smoker** | Ha fumado al menos 100 cigarrillos en su vida (1 = sí, 0 = no). |
| **Stroke** | Ha sufrido un accidente cerebrovascular (1 = sí, 0 = no). |
| **HeartDiseaseorAttack** | Infarto, angina o enfermedad coronaria (1 = sí, 0 = no). |
| **PhysActivity** | Actividad física en los últimos 30 días (1 = sí, 0 = no). |
| **Fruits** | Consume frutas diariamente (1 = sí, 0 = no). |
| **Veggies** | Consume vegetales diariamente (1 = sí, 0 = no). |
| **HvyAlcoholConsump** | Consumo excesivo de alcohol (1 = sí, 0 = no). |
| **AnyHealthcare** | Tiene cobertura de salud o seguro médico (1 = sí, 0 = no). |
| **NoDocbcCost** | Requirió atención médica pero no pudo pagar (1 = sí, 0 = no). |
| **GenHlth** | Salud general percibida (escala 1–5). |
| **MentHlth** | Días con mala salud mental en el último mes (0–30). |
| **PhysHlth** | Días con mala salud física en el último mes (0–30). |
| **DiffWalk** | Dificultad para caminar o subir escaleras (1 = sí, 0 = no). |
| **Sex** | 0 = mujer, 1 = hombre. |
| **Age** | Categoría de edad (escala 1–13). |
| **Education** | Nivel educativo (escala 1–6). |
| **Income** | Nivel de ingresos (escala 1–8). |

---

## Diccionario de escalas (según Codebook BRFSS 2015)

Estas son las variables que poseen escalas ordinales específicas.  
Fuente oficial: https://www.cdc.gov/brfss/annual_data/2015/pdf/codebook15_llcp.pdf


### Age — `_AGEG5YR`
Categorías de edad en intervalos de 5 años.

| Valor | Rango |
|-------|--------|
| 1 | 18–24 años |
| 2 | 25–29 años |
| 3 | 30–34 años |
| 4 | 35–39 años |
| 5 | 40–44 años |
| 6 | 45–49 años |
| 7 | 50–54 años |
| 8 | 55–59 años |
| 9 | 60–64 años |
| 10 | 65–69 años |
| 11 | 70–74 años |
| 12 | 75–79 años |
| 13 | 80 años o más |
| 14 | Don’t know / Refused / Missing |

---

### Education — `EDUCA`
Nivel educativo alcanzado.

| Valor | Nivel |
|-------|--------|
| 1 | Nunca asistió / solo kindergarten |
| 2 | Grados 1–8 |
| 3 | Grados 9–11 |
| 4 | Grado 12 o GED |
| 5 | College 1–3 años |
| 6 | College 4+ años |
| 9 | Refused |

---

### Income — `INCOME2`
Rango de ingresos del hogar al año.

| Valor | Ingresos |
|-------|-----------|
| 1 | < $10,000 |
| 2 | $10,000–14,999 |
| 3 | $15,000–19,999 |
| 4 | $20,000–24,999 |
| 5 | $25,000–34,999 |
| 6 | $35,000–49,999 |
| 7 | $50,000–74,999 |
| 8 | ≥ $75,000 |
| 77 | Don’t know |
| 99 | Refused |

---

### GenHlth
Salud general percibida.

| Valor | Estado |
|-------|---------|
| 1 | Excelente |
| 2 | Muy buena |
| 3 | Buena |
| 4 | Regular |
| 5 | Mala |




