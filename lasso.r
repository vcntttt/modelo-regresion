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
# 2. MODELOS LOGÍSTICOS
# =====================================================================

modelo_completo <- glm(diagnosis ~ ., data=df, family=binomial)

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
# 3. PREPARACIÓN DE DATOS PARA REGULARIZACIÓN
# =====================================================================

X <- as.matrix(df[, -1])
y <- ifelse(df$diagnosis == "Maligno", 1, 0)

# =====================================================================
# 4. LASSO LOGÍSTICO (L1 regularization)
# =====================================================================

# Cross-validation para encontrar lambda óptimo
cv_lasso <- cv.glmnet(
  X, y,
  family = "binomial",
  alpha = 1,              # LASSO (L1 penalty)
  nfolds = 10,
  type.measure = "class"
)

# lambdas óptimos
lambda_min <- cv_lasso$lambda.min    # Mínimo error de CV
lambda_1se <- cv_lasso$lambda.1se    # Regla 1-SE (más parsimonioso)

# --- Modelo LASSO con lambda.min ---
coef_lasso_min <- coef(cv_lasso, s = "lambda.min")
vars_lasso_min <- rownames(coef_lasso_min)[coef_lasso_min[, 1] != 0]
vars_lasso_min <- vars_lasso_min[vars_lasso_min != "(Intercept)"]

formula_lasso_min <- as.formula(
  paste("diagnosis ~", paste(vars_lasso_min, collapse = " + "))
)
modelo_lasso_min <- glm(formula_lasso_min, data = df, family = binomial)

# --- Modelo LASSO con lambda.1se ---
coef_lasso_1se <- coef(cv_lasso, s = "lambda.1se")
vars_lasso_1se <- rownames(coef_lasso_1se)[coef_lasso_1se[, 1] != 0]
vars_lasso_1se <- vars_lasso_1se[vars_lasso_1se != "(Intercept)"]

formula_lasso_1se <- as.formula(
  paste("diagnosis ~", paste(vars_lasso_1se, collapse = " + "))
)
modelo_lasso_1se <- glm(formula_lasso_1se, data = df, family = binomial)

# curva de CV de LASSO
pdf("plots/modelos/lasso_cv_curve.pdf", width = 8, height = 6)
plot(cv_lasso, main = "LASSO: Cross-Validation Curve")
abline(v = log(lambda_min), col = "red", lty = 2)
abline(v = log(lambda_1se), col = "blue", lty = 2)
legend("topright", 
       legend = c("lambda.min", "lambda.1se"),
       col = c("red", "blue"), lty = 2, cex = 0.8)
dev.off()

# =====================================================================
# 5. RIDGE LOGÍSTICO (L2 regularization)
# =====================================================================

# Cross-validation para encontrar lambda óptimo
cv_ridge <- cv.glmnet(
  X, y,
  family = "binomial",
  alpha = 0,              # Ridge (L2 penalty)
  nfolds = 10,
  type.measure = "class"
)

# lambdas óptimos
lambda_ridge_min <- cv_ridge$lambda.min
lambda_ridge_1se <- cv_ridge$lambda.1se

# --- Modelo RIDGE con lambda.min ---
coef_ridge_min <- coef(cv_ridge, s = "lambda.min")
vars_ridge_min <- rownames(coef_ridge_min)[coef_ridge_min[, 1] != 0]
vars_ridge_min <- vars_ridge_min[vars_ridge_min != "(Intercept)"]

formula_ridge_min <- as.formula(
  paste("diagnosis ~", paste(vars_ridge_min, collapse = " + "))
)
modelo_ridge_min <- glm(formula_ridge_min, data = df, family = binomial)

# --- Modelo RIDGE con lambda.1se ---
coef_ridge_1se <- coef(cv_ridge, s = "lambda.1se")
vars_ridge_1se <- rownames(coef_ridge_1se)[coef_ridge_1se[, 1] != 0]
vars_ridge_1se <- vars_ridge_1se[vars_ridge_1se != "(Intercept)"]

formula_ridge_1se <- as.formula(
  paste("diagnosis ~", paste(vars_ridge_1se, collapse = " + "))
)
modelo_ridge_1se <- glm(formula_ridge_1se, data = df, family = binomial)

# curva de CV de RIDGE
pdf("plots/modelos/ridge_cv_curve.pdf", width = 8, height = 6)
plot(cv_ridge, main = "Ridge: Cross-Validation Curve")
abline(v = log(lambda_ridge_min), col = "red", lty = 2)
abline(v = log(lambda_ridge_1se), col = "blue", lty = 2)
legend("topright", 
       legend = c("lambda.min", "lambda.1se"),
       col = c("red", "blue"), lty = 2, cex = 0.8)
dev.off()



# =====================================================================
# 6. DIAGNÓSTICOS DE LOS MODELOS
# =====================================================================

pdf("plots/modelos/diagnosticos_modelos.pdf", width = 10, height = 10)

modelos <- list(
  "Modelo completo"      = modelo_completo,
  "Modelo A"             = modelo_A,
  "Modelo B"             = modelo_B,
  "Modelo C"             = modelo_C,
  "Modelo D"             = modelo_D,
  "LASSO (lambda.min)"   = modelo_lasso_min,
  "LASSO (lambda.1se)"   = modelo_lasso_1se,
  "Ridge (lambda.min)"   = modelo_ridge_min,
  "Ridge (lambda.1se)"   = modelo_ridge_1se
)

for (nombre in names(modelos)) {
  plot.new()
  text(0.5, 0.5, nombre, cex = 2, font = 2)
  plot(modelos[[nombre]])
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

pca <- prcomp(vars, scale.=TRUE)

scores <- as.data.frame(pca$x[, 1:2])
scores$diagnosis <- df$diagnosis

pdf("plots/variables/pca_scores.pdf", width=8, height=6)

p <- ggplot(scores, aes(PC1, PC2, color=diagnosis)) +
  geom_point(alpha=0.6, size=2) +
  stat_ellipse(level=0.95, linetype="solid") +
  theme_minimal(base_size = 18) +
  scale_color_manual(values=c("#1E88E5","#E53935")) +
  labs(title = "Análisis de Componentes Principales (PCA)")

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

pdf("plots/variables/heatmap_wdbc.pdf", width=14, height=12)

p <- ggplot(M_melt, aes(x = Var1, y = Var2, fill = Cor)) +
  geom_tile(color = "white", linewidth = 0.1) +
  scale_fill_gradient2(
    low = "#2166ac", mid = "white", high = "#b2182b",
    midpoint = 0, limits = c(-1,1),
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
    panel.border = element_rect(color="black", fill=NA, linewidth=0.3)
  ) +
  labs(
    title = "Mapa de calor de correlaciones — WDBC",
    x = "",
    y = ""
  )

print(p)
dev.off()

# =====================================================================
# 11. GENERAR LOGS DE RESULTADOS
# =====================================================================

# ---------------------------------------------------------------------
# 11.1. COMPARACIÓN DE MODELOS (AIC y Pseudo-R²)
# ---------------------------------------------------------------------

sink("logs/01_comparacion_modelos.log")

cat("==========================================================\n")
cat(" COMPARACIÓN DE MODELOS — WDBC\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n")

cat("==========================================================\n")
cat(" COMPARACIÓN POR AIC (menor es mejor)\n")
cat("==========================================================\n")
aics <- sapply(modelos, AIC)
aic_table <- data.frame(Model = names(aics), AIC = as.numeric(aics), row.names = NULL)
aic_table <- aic_table[order(aic_table$AIC), ]
print(aic_table)
cat("\n\n")

cat("==========================================================\n")
cat(" PSEUDO-R² (McFadden, Cox–Snell, Nagelkerke)\n")
cat("==========================================================\n\n")

for (nombre in names(modelos)) {
  cat("----------------------------------------------------------\n")
  cat(" ", nombre, "\n")
  cat("----------------------------------------------------------\n")
  print(pR2(modelos[[nombre]]))
  cat("\n")
}

sink()

# ---------------------------------------------------------------------
# 11.2. DETALLES DE LASSO
# ---------------------------------------------------------------------

sink("logs/02_lasso.log")

cat("==========================================================\n")
cat(" LASSO — SELECCIÓN AUTOMÁTICA DE VARIABLES\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n")

cat("LASSO (Least Absolute Shrinkage and Selection Operator)\n")
cat("Regularización L1: Penaliza |β|, forzando coeficientes a 0.\n")
cat("Resultado: Selección automática de variables.\n\n")

cat("----------------------------------------------------------\n")
cat(" CROSS-VALIDATION\n")
cat("----------------------------------------------------------\n")
cat("λ óptimo (lambda.min): ", lambda_min, "\n")
cat("  → Minimiza el error de clasificación\n\n")
cat("λ 1-SE (lambda.1se):   ", lambda_1se, "\n")
cat("  → Modelo más parsimonioso dentro de 1 error estándar\n\n")

cat("==========================================================\n")
cat(" VARIABLES SELECCIONADAS — lambda.min\n")
cat("==========================================================\n")
cat("Total: ", length(vars_lasso_min), " variables\n\n")
cat("Variables:\n")
for (v in vars_lasso_min) {
  cat("  • ", v, "\n")
}
cat("\n")

cat("Coeficientes:\n")
print(coef_lasso_min)
cat("\n\n")

cat("==========================================================\n")
cat(" VARIABLES SELECCIONADAS — lambda.1se (más parsimonioso)\n")
cat("==========================================================\n")
cat("Total: ", length(vars_lasso_1se), " variables\n\n")
cat("Variables:\n")
for (v in vars_lasso_1se) {
  cat("  • ", v, "\n")
}
cat("\n")

cat("Coeficientes:\n")
print(coef_lasso_1se)
cat("\n")

sink()

# ---------------------------------------------------------------------
# 11.3. DETALLES DE RIDGE
# ---------------------------------------------------------------------

sink("logs/03_ridge.log")

cat("==========================================================\n")
cat(" RIDGE — REGULARIZACIÓN L2\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n")

cat("Ridge Regression\n")
cat("Regularización L2: Penaliza β², reduciendo magnitud de coeficientes.\n")
cat("Resultado: Mantiene todas las variables pero con coeficientes reducidos.\n")
cat("No realiza selección de variables como LASSO.\n\n")

cat("----------------------------------------------------------\n")
cat(" CROSS-VALIDATION\n")
cat("----------------------------------------------------------\n")
cat("λ óptimo (lambda.min): ", lambda_ridge_min, "\n")
cat("  → Minimiza el error de clasificación\n\n")
cat("λ 1-SE (lambda.1se):   ", lambda_ridge_1se, "\n")
cat("  → Mayor penalización, coeficientes más reducidos\n\n")

cat("==========================================================\n")
cat(" COEFICIENTES — lambda.min\n")
cat("==========================================================\n")
print(coef_ridge_min)
cat("\n\n")

cat("==========================================================\n")
cat(" COEFICIENTES — lambda.1se (mayor regularización)\n")
cat("==========================================================\n")
print(coef_ridge_1se)
cat("\n")

sink()

# ---------------------------------------------------------------------
# 11.4. SUMMARIES COMPLETOS
# ---------------------------------------------------------------------

sink("logs/04_summaries.log")

cat("==========================================================\n")
cat(" SUMMARIES COMPLETOS DE TODOS LOS MODELOS\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n\n")

for (nombre in names(modelos)) {
  cat("==========================================================\n")
  cat(" ", nombre, "\n")
  cat("==========================================================\n")
  print(summary(modelos[[nombre]]))
  cat("\n\n\n")
}

sink()
