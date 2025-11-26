packages <- c(
  "ggplot2", "gclus", "corrplot", "pscl", "broom",
  "reshape2", "dplyr", "tidyr", "GGally", "glmnet"
)

install.packages(setdiff(packages, rownames(installed.packages())))
lapply(packages, library, character.only = TRUE)

set.seed(1406)

# =====================================================================
# 1. CARGA DE DATOS Y FILTRO DE VARIABLES
# =====================================================================

df <- read.csv("breast_cancer_wisconsin_diagnostic.csv")

df <- df[, colSums(is.na(df)) < nrow(df)]
df <- df[, sapply(df, function(x) length(unique(x)) > 1)]

df$diagnosis <- factor(df$diagnosis,
                       levels = c("B","M"),
                       labels = c("Benigno","Maligno"))

df <- df %>% select(diagnosis, ends_with("_mean"))

vars <- df[, setdiff(names(df), "diagnosis")]

# =====================================================================
# 2. MODELOS LOGÍSTICOS CLÁSICOS (SIN PENALIZACIÓN)
# =====================================================================

modelo_completo <- glm(diagnosis ~ ., data = df, family = binomial)

modelo_A <- glm(
  diagnosis ~ radius_mean + concave.points_mean + texture_mean,
  data = df,
  family = binomial
)

modelo_B <- glm(
  diagnosis ~ concave.points_mean + texture_mean,
  data = df,
  family = binomial
)

modelo_C <- glm(
  diagnosis ~ radius_mean + concave.points_mean,
  data = df,
  family = binomial
)

modelo_D <- glm(
  diagnosis ~ radius_mean + concave.points_mean + symmetry_mean,
  data = df,
  family = binomial
)

# =====================================================================
# 3. PREPARACIÓN DE DATOS PARA REGULARIZACIÓN (glmnet)
# =====================================================================

X <- as.matrix(df[, -1])
y <- ifelse(df$diagnosis == "Maligno", 1, 0)

# =====================================================================
# 4. LASSO LOGÍSTICO (L1 regularization)
# =====================================================================

cv_lasso <- cv.glmnet(
  X, y,
  family = "binomial",
  alpha = 1,              # LASSO (L1 penalty)
  nfolds = 10,
  type.measure = "class"
)

lambda_min  <- cv_lasso$lambda.min    # Mínimo error de CV
lambda_1se  <- cv_lasso$lambda.1se    # Regla 1-SE (más parsimonioso)

# --- Modelo post-LASSO con lambda.min ---
coef_lasso_min <- coef(cv_lasso, s = "lambda.min")
vars_lasso_min <- rownames(coef_lasso_min)[coef_lasso_min[, 1] != 0]
vars_lasso_min <- vars_lasso_min[vars_lasso_min != "(Intercept)"]

formula_lasso_min <- as.formula(
  paste("diagnosis ~", paste(vars_lasso_min, collapse = " + "))
)
modelo_lasso_min <- glm(formula_lasso_min, data = df, family = binomial)

# --- Modelo post-LASSO con lambda.1se ---
coef_lasso_1se <- coef(cv_lasso, s = "lambda.1se")
vars_lasso_1se <- rownames(coef_lasso_1se)[coef_lasso_1se[, 1] != 0]
vars_lasso_1se <- vars_lasso_1se[vars_lasso_1se != "(Intercept)"]

formula_lasso_1se <- as.formula(
  paste("diagnosis ~", paste(vars_lasso_1se, collapse = " + "))
)
modelo_lasso_1se <- glm(formula_lasso_1se, data = df, family = binomial)

# Curva de CV de LASSO
pdf("plots/modelos/lasso_cv_curve.pdf", width = 8, height = 6)
plot(cv_lasso)
abline(v = -log(lambda_min),  col = "red",  lty = 2)
abline(v = -log(lambda_1se),  col = "blue", lty = 2)
legend("topright", 
       legend = c("lambda.min", "lambda.1se"),
       col = c("red", "blue"), lty = 2, cex = 0.8)
dev.off()

# =====================================================================
# 5. RIDGE LOGÍSTICO (L2 regularization)
# =====================================================================

cv_ridge <- cv.glmnet(
  X, y,
  family = "binomial",
  alpha = 0,              # Ridge (L2 penalty)
  nfolds = 10,
  type.measure = "class"
)

lambda_ridge_min <- cv_ridge$lambda.min
lambda_ridge_1se <- cv_ridge$lambda.1se

# Coeficientes Ridge (penalizados)
coef_ridge_min  <- coef(cv_ridge, s = "lambda.min")
coef_ridge_1se  <- coef(cv_ridge, s = "lambda.1se")

# Curva de CV de RIDGE
pdf("plots/modelos/ridge_cv_curve.pdf", width = 8, height = 6)
plot(cv_ridge)
abline(v = -log(lambda_ridge_min),  col = "red",  lty = 2)
abline(v = -log(lambda_ridge_1se),  col = "blue", lty = 2)
legend("topright", 
       legend = c("lambda.min", "lambda.1se"),
       col = c("red", "blue"), lty = 2, cex = 0.8)
dev.off()

# =====================================================================
# 6. DIAGNÓSTICOS DE MODELOS GLM (SIN PENALIZACIÓN)
# =====================================================================

# Solo modelos logísticos "clásicos" + post-LASSO
modelos_glm <- list(
  "Modelo completo"      = modelo_completo,
  "Modelo A"             = modelo_A,
  "Modelo B"             = modelo_B,
  "Modelo C"             = modelo_C,
  "Modelo D"             = modelo_D,
  "LASSO (lambda.min)"   = modelo_lasso_min,
  "LASSO (lambda.1se)"   = modelo_lasso_1se
)

pdf("plots/modelos/diagnosticos_modelos.pdf", width = 10, height = 10)

for (nombre in names(modelos_glm)) {
  plot.new()
  text(0.5, 0.5, nombre, cex = 2, font = 2)
  plot(modelos_glm[[nombre]])
}

dev.off()

# =====================================================================
# 7. PAIRS PLOT (GGPAIRS)
# =====================================================================

pdf("plots/variables/pairs_wdbc.pdf", width = 20, height = 20)

g <- ggpairs(
  vars,
  title = "Interacción entre variables predictoras — WDBC",
  upper = list(continuous = wrap("cor", size = 3)),
  lower = list(continuous = wrap("points", alpha = 0.4, size = 0.8)),
  diag  = list(continuous = wrap("densityDiag"))
) +
  theme_bw() +
  theme(
    text = element_text(size = 6),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 5),
    axis.text.y = element_text(size = 5),
    strip.text = element_text(size = 7)
  )

print(g)
dev.off()

# =====================================================================
# 8. CPAIRS (gclus)
# =====================================================================

corr_mat <- abs(cor(vars))
corr_colors <- dmat.color(corr_mat)
order_vars <- order.single(corr_mat)

pdf("plots/variables/cpairs_wdbc.pdf", width = 20, height = 20)

par(cex = 0.6)
par(cex.axis = 0.5)
par(mar = c(5,5,3,1))

cpairs(
  vars,
  order_vars,
  panel.colors = corr_colors,
  gap = 0.5,
  main = "Interacción entre variables predictoras (WDBC)"
)

dev.off()

# =====================================================================
# 9. PCA (scores)
# =====================================================================

pca <- prcomp(vars, scale. = TRUE)

scores <- as.data.frame(pca$x[, 1:2])
scores$diagnosis <- df$diagnosis

pdf("plots/variables/pca_scores.pdf", width = 8, height = 6)

p <- ggplot(scores, aes(PC1, PC2, color = diagnosis)) +
  geom_point(alpha = 0.6, size = 2) +
  stat_ellipse(level = 0.95, linetype = "solid") +
  theme_minimal(base_size = 18) +
  scale_color_manual(values = c("#1E88E5","#E53935")) +
  labs(title = "")

print(p)
dev.off()

# =====================================================================
# 10. HEATMAP
# =====================================================================

M <- cor(vars)
hc <- hclust(dist(M))
M_ord <- M[hc$order, hc$order]
M_melt <- melt(M_ord)
colnames(M_melt) <- c("Var1", "Var2", "Cor")

pdf("plots/variables/heatmap_wdbc.pdf", width = 14, height = 12)

p <- ggplot(M_melt, aes(x = Var1, y = Var2, fill = Cor)) +
  geom_tile(color = "white", linewidth = 0.1) +
  scale_fill_gradient2(
    low = "#2166ac", mid = "white", high = "#b2182b",
    midpoint = 0, limits = c(-1, 1),
    name = "Correlación"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.x = element_text(angle = 60, vjust = 1, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    plot.title = element_text(size = 20, face = "bold"),
    legend.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 12),
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.3)
  ) +
  labs(
    title = "",
    x = "",
    y = ""
  )

print(p)
dev.off()

# =====================================================================
# 11. MÉTRICAS DE DESEMPEÑO (ACCURACY) — GLM vs PENALIZADOS
# =====================================================================

# Función para accuracy de un glm clásico
accuracy_glm <- function(mod, data, y_name = "diagnosis") {
  p <- predict(mod, type = "response")
  y_real <- ifelse(data[[y_name]] == "Maligno", 1, 0)
  y_hat  <- ifelse(p > 0.5, 1, 0)
  mean(y_hat == y_real)
}

# Accuracy de modelos GLM (sin penalización)
acc_completo    <- accuracy_glm(modelo_completo, df)
acc_A           <- accuracy_glm(modelo_A, df)
acc_B           <- accuracy_glm(modelo_B, df)
acc_C           <- accuracy_glm(modelo_C, df)
acc_D           <- accuracy_glm(modelo_D, df)
acc_lasso_min   <- accuracy_glm(modelo_lasso_min, df)
acc_lasso_1se   <- accuracy_glm(modelo_lasso_1se, df)

# Accuracy de modelos penalizados (directo desde glmnet)
p_lasso_min   <- predict(cv_lasso, newx = X, s = "lambda.min",  type = "response")
p_lasso_1se   <- predict(cv_lasso, newx = X, s = "lambda.1se",  type = "response")
p_ridge_min   <- predict(cv_ridge, newx = X, s = "lambda.min",  type = "response")
p_ridge_1se   <- predict(cv_ridge, newx = X, s = "lambda.1se",  type = "response")

y_bin <- ifelse(df$diagnosis == "Maligno", 1, 0)

acc_lasso_min_pen  <- mean(ifelse(p_lasso_min  > 0.5, 1, 0) == y_bin)
acc_lasso_1se_pen  <- mean(ifelse(p_lasso_1se  > 0.5, 1, 0) == y_bin)
acc_ridge_min_pen  <- mean(ifelse(p_ridge_min  > 0.5, 1, 0) == y_bin)
acc_ridge_1se_pen  <- mean(ifelse(p_ridge_1se  > 0.5, 1, 0) == y_bin)

tabla_acc <- data.frame(
  Modelo = c(
    "GLM completo",
    "GLM A",
    "GLM B",
    "GLM C",
    "GLM D",
    "Post-LASSO (lambda.min)",
    "Post-LASSO (lambda.1se)",
    "LASSO penalizado (lambda.min)",
    "LASSO penalizado (lambda.1se)",
    "Ridge penalizado (lambda.min)",
    "Ridge penalizado (lambda.1se)"
  ),
  Accuracy = c(
    acc_completo,
    acc_A,
    acc_B,
    acc_C,
    acc_D,
    acc_lasso_min,
    acc_lasso_1se,
    acc_lasso_min_pen,
    acc_lasso_1se_pen,
    acc_ridge_min_pen,
    acc_ridge_1se_pen
  )
)

# Ordenar tabla por Accuracy (de mayor a menor)
tabla_acc <- tabla_acc[order(tabla_acc$Accuracy, decreasing = TRUE), ]
rownames(tabla_acc) <- NULL

# =====================================================================
# 12. GENERAR LOGS DE RESULTADOS
# =====================================================================

# ---------------------------------------------------------------------
# 12.1. COMPARACIÓN DE MODELOS (AIC y Pseudo-R²) — SOLO GLM
# ---------------------------------------------------------------------

sink("logs/01_aic-r2.log")

cat("==========================================================\n")
cat(" COMPARACIÓN DE MODELOS — WDBC\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n")

cat("==========================================================\n")
cat(" COMPARACIÓN POR AIC (menor es mejor)\n")
cat("==========================================================\n")
aics <- sapply(modelos_glm, AIC)
aic_table <- data.frame(Model = names(aics), AIC = as.numeric(aics), row.names = NULL)
aic_table <- aic_table[order(aic_table$AIC), ]
print(aic_table)
cat("\n\n")

cat("==========================================================\n")
cat(" PSEUDO-R² (McFadden, Cox–Snell, Nagelkerke)\n")
cat("==========================================================\n\n")

for (nombre in names(modelos_glm)) {
  cat("----------------------------------------------------------\n")
  cat(" ", nombre, "\n")
  cat("----------------------------------------------------------\n")
  print(pR2(modelos_glm[[nombre]]))
  cat("\n")
}

sink()

# ---------------------------------------------------------------------
# 12.2. DETALLES DE LASSO
# ---------------------------------------------------------------------

sink("logs/02_lasso.log")

cat("==========================================================\n")
cat(" LASSO — SELECCIÓN AUTOMÁTICA DE VARIABLES\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n")

cat("LASSO (Least Absolute Shrinkage and Selection Operator)\n")
cat("Regularización L1: Penaliza |β|, forzando algunos coeficientes a 0.\n")
cat("Resultado: Selección automática de variables.\n\n")

cat("----------------------------------------------------------\n")
cat(" CROSS-VALIDATION\n")
cat("----------------------------------------------------------\n")
cat("λ óptimo (lambda.min): ", lambda_min, "\n")
cat("  → Minimiza el error de clasificación\n\n")
cat("λ 1-SE (lambda.1se):   ", lambda_1se, "\n")
cat("  → Modelo más parsimonioso dentro de 1 error estándar\n\n")

cat("==========================================================\n")
cat(" VARIABLES SELECCIONADAS — lambda.min (post-LASSO)\n")
cat("==========================================================\n")
cat("Total: ", length(vars_lasso_min), " variables\n\n")
cat("Variables:\n")
for (v in vars_lasso_min) {
  cat("  • ", v, "\n")
}
cat("\n")

cat("Coeficientes penalizados (glmnet):\n")
print(coef_lasso_min)
cat("\n\n")

cat("==========================================================\n")
cat(" VARIABLES SELECCIONADAS — lambda.1se (post-LASSO, más parsimonioso)\n")
cat("==========================================================\n")
cat("Total: ", length(vars_lasso_1se), " variables\n\n")
cat("Variables:\n")
for (v in vars_lasso_1se) {
  cat("  • ", v, "\n")
}
cat("\n")

cat("Coeficientes penalizados (glmnet):\n")
print(coef_lasso_1se)
cat("\n")

sink()

# ---------------------------------------------------------------------
# 12.3. DETALLES DE RIDGE
# ---------------------------------------------------------------------

sink("logs/03_ridge.log")

cat("==========================================================\n")
cat(" RIDGE — REGULARIZACIÓN L2\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n")

cat("Ridge Regression\n")
cat("Regularización L2: Penaliza β², reduciendo la magnitud de los coeficientes.\n")
cat("Resultado: Mantiene todas las variables, pero con coeficientes encogidos.\n")
cat("No realiza selección de variables como LASSO.\n\n")

cat("----------------------------------------------------------\n")
cat(" CROSS-VALIDATION\n")
cat("----------------------------------------------------------\n")
cat("λ óptimo (lambda.min): ", lambda_ridge_min, "\n")
cat("  → Minimiza el error de clasificación\n\n")
cat("λ 1-SE (lambda.1se):   ", lambda_ridge_1se, "\n")
cat("  → Mayor penalización, coeficientes más reducidos\n\n")

cat("==========================================================\n")
cat(" COEFICIENTES PENALIZADOS — lambda.min\n")
cat("==========================================================\n")
print(coef_ridge_min)
cat("\n\n")

cat("==========================================================\n")
cat(" COEFICIENTES PENALIZADOS — lambda.1se (mayor regularización)\n")
cat("==========================================================\n")
print(coef_ridge_1se)
cat("\n")

sink()

# ---------------------------------------------------------------------
# 12.4. SUMMARIES COMPLETOS (SOLO MODELOS GLM SIN PENALIZACIÓN)
# ---------------------------------------------------------------------

sink("logs/04_summaries.log")

cat("==========================================================\n")
cat(" SUMMARIES COMPLETOS DE TODOS LOS MODELOS GLM\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n\n")

for (nombre in names(modelos_glm)) {
  cat("==========================================================\n")
  cat(" ", nombre, "\n")
  cat("==========================================================\n")
  print(summary(modelos_glm[[nombre]]))
  cat("\n\n\n")
}

sink()

# ---------------------------------------------------------------------
# 12.5. LOG DE ACCURACY (GLM vs PENALIZADOS)
# ---------------------------------------------------------------------

sink("logs/05_accuracy_modelos.log")

cat("==========================================================\n")
cat(" ACCURACY DE MODELOS (ENTRENAMIENTO)\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n")
print(tabla_acc)
cat("\n")

sink()
