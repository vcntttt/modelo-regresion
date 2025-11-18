df <- read.csv("diabetes_binary_5050split_health_indicators_BRFSS2015.csv")
head(df)

# Variable objetivo: la dejo como factor con niveles 0 y 1
df$Diabetes_binary <- factor(df$Diabetes_binary,
                             levels = c(0, 1),
                             labels = c("NoDiabetes", "Diabetes"))

# Variables ordinales según el codebook
# Age: 1–13 (categorías de edad en tramos de 5 años)
df$Age <- factor(df$Age,
                 levels = sort(unique(df$Age)),
                 ordered = TRUE)

# Education: 1–6 (nivel educativo)
df$Education <- factor(df$Education,
                       levels = sort(unique(df$Education)),
                       ordered = TRUE)

# Income: 1–8 (tramos de ingreso)
df$Income <- factor(df$Income,
                    levels = sort(unique(df$Income)),
                    ordered = TRUE)

# GenHlth: 1–5 (1 = excelente, 5 = mala)
df$GenHlth <- factor(df$GenHlth,
                     levels = sort(unique(df$GenHlth)),
                     ordered = TRUE)
bin_vars <- c("HighBP", "HighChol", "CholCheck", "Smoker", "Stroke",
              "HeartDiseaseorAttack", "PhysActivity", "Fruits", "Veggies",
              "HvyAlcoholConsump", "AnyHealthcare", "NoDocbcCost",
              "DiffWalk", "Sex")

for (v in bin_vars) {
  df[[v]] <- factor(df[[v]], levels = c(0, 1))
}


modelo <- glm(Diabetes_binary ~ ., data = df, family = binomial)
summary(modelo)

modelo_clinico <- glm(
  Diabetes_binary ~ HighBP + HighChol + BMI + HeartDiseaseorAttack +
    Stroke + DiffWalk + GenHlth,
  data = df,
  family = binomial
)

summary(modelo_clinico)

modelo_estilo_vida <- glm(
  Diabetes_binary ~ Smoker + HvyAlcoholConsump + PhysActivity + 
    Fruits + Veggies + BMI + PhysHlth + MentHlth + GenHlth,
  data = df,
  family = binomial
)

summary(modelo_estilo_vida)

modelo_socioeconomico <- glm(
  Diabetes_binary ~ Education + Income + AnyHealthcare + NoDocbcCost +
    Sex + Age + GenHlth,
  data = df,
  family = binomial
)

summary(modelo_socioeconomico)

modelo_compacto <- glm(
  Diabetes_binary ~ HighBP + HighChol + BMI + Age + GenHlth,
  data = df,
  family = binomial
)

summary(modelo_compacto)

AIC(modelo, modelo_clinico, modelo_estilo_vida, modelo_socioeconomico, modelo_compacto)


