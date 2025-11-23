packages <- c(
  "ggplot2", "gclus", "corrplot", "pscl", "broom",
  "reshape2", "dplyr", "tidyr", "GGally", "glmnet"
)

install.packages(setdiff(packages, rownames(installed.packages())))
lapply(packages, library, character.only = TRUE)

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
# 3. LASSO LOGÍSTICO (glmnet)
# =====================================================================

# X como matriz (solo numéricas)
X <- as.matrix(df[, -1])  

# y como 0/1
y <- ifelse(df$diagnosis == "Maligno", 1, 0)

set.seed(123)

cv_lasso <- cv.glmnet(
  X, y,
  family = "binomial",
  alpha = 1,           # LASSO puro
  nfolds = 10
)

lambda_min <- cv_lasso$lambda.min
lambda_1se <- cv_lasso$lambda.1se

# =====================================================================
# 3.1. EXTRAER VARIABLES SELECCIONADAS POR LASSO
# =====================================================================

coef_min <- coef(cv_lasso, s="lambda.min")
vars_lasso_min <- rownames(coef_min)[coef_min[,1] != 0]
vars_lasso_min <- vars_lasso_min[vars_lasso_min != "(Intercept)"]

# Fórmula del modelo LASSO final
formula_lasso <- as.formula(
  paste("diagnosis ~", paste(vars_lasso_min, collapse=" + "))
)

modelo_lasso_glm <- glm(formula_lasso, data=df, family=binomial)


coef_1se <- coef(cv_lasso, s="lambda.1se")
vars_lasso_1se <- rownames(coef_1se)[coef_1se[,1] != 0]
vars_lasso_1se <- vars_lasso_1se[vars_lasso_1se != "(Intercept)"]

formula_lasso_1se <- as.formula(
  paste("diagnosis ~", paste(vars_lasso_1se, collapse=" + "))
)

modelo_lasso_1se_glm <- glm(formula_lasso_1se, data=df, family=binomial)
# =====================================================================
# 3.2 GUARDAR GRÁFICO DE LASSO
# =====================================================================

pdf("plots/lasso_cv_curve.pdf", width=8, height=6)
plot(cv_lasso)
dev.off()


# =====================================================================
# 4. RIDGE LOGÍSTICO (glmnet alpha = 0)
# =====================================================================

set.seed(123)

cv_ridge <- cv.glmnet(
  X, y,
  family = "binomial",
  alpha = 0,       # ridge puro
  nfolds = 10
)

ridge_lambda_min  <- cv_ridge$lambda.min
ridge_lambda_1se  <- cv_ridge$lambda.1se

# Coeficientes para lambda.min
coef_ridge_min <- coef(cv_ridge, s = "lambda.min")
vars_ridge_min <- rownames(coef_ridge_min)[coef_ridge_min[, 1] != 0]
vars_ridge_min <- vars_ridge_min[vars_ridge_min != "(Intercept)"]

formula_ridge_min <- as.formula(
  paste("diagnosis ~", paste(vars_ridge_min, collapse = " + "))
)
modelo_ridge_min_glm <- glm(formula_ridge_min, data = df, family = binomial)

# Coeficientes para lambda.1se
coef_ridge_1se <- coef(cv_ridge, s = "lambda.1se")
vars_ridge_1se <- rownames(coef_ridge_1se)[coef_ridge_1se[, 1] != 0]
vars_ridge_1se <- vars_ridge_1se[vars_ridge_1se != "(Intercept)"]

formula_ridge_1se <- as.formula(
  paste("diagnosis ~", paste(vars_ridge_1se, collapse = " + "))
)
modelo_ridge_1se_glm <- glm(formula_ridge_1se, data = df, family = binomial)

# Guardar gráfico
pdf("plots/lasso/ridge_cv_curve.pdf", width = 8, height = 6)
plot(cv_ridge)
dev.off()



# =====================================================================
# 5. DIAGNÓSTICOS DE LOS MODELOS
# =====================================================================

pdf("plots/lasso/diagnosticos_modelos.pdf", width = 10, height = 10)

modelos <- list(
  "Modelo completo"      = modelo_completo,
  "Modelo A"             = modelo_A,
  "Modelo B"             = modelo_B,
  "Modelo C"             = modelo_C,
  "Modelo D"             = modelo_D,
  "Modelo LASSO"         = modelo_lasso_glm,
  "Modelo LASSO 1-SE"    = modelo_lasso_1se_glm,
  "Modelo RIDGE"         = modelo_ridge_min_glm,
  "Modelo RIDGE 1-SE"    = modelo_ridge_1se_glm
)

for (nombre in names(modelos)) {
  plot.new()
  text(0.5, 0.5, nombre, cex = 2, font = 2)
  plot(modelos[[nombre]])
}

dev.off()

# =====================================================================
# 6. PAIRS PLOT (GGPAIRS)
# =====================================================================

pdf("plots/lasso/pairs_wdbc.pdf", width = 20, height = 20)

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
# 7. CPAIRS (gclus)
# =====================================================================

corr_mat <- abs(cor(vars))
corr_colors <- dmat.color(corr_mat)
order_vars <- order.single(corr_mat)

pdf("plots/lasso/cpairs_wdbc.pdf", width = 20, height = 20)

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
# 8. PCA (scores)
# =====================================================================

pca <- prcomp(vars, scale.=TRUE)

scores <- as.data.frame(pca$x[, 1:2])
scores$diagnosis <- df$diagnosis

pdf("plots/lasso/pca_scores.pdf", width=8, height=6)

p <- ggplot(scores, aes(PC1, PC2, color=diagnosis)) +
  geom_point(alpha=0.6, size=2) +
  stat_ellipse(level=0.95, linetype="solid") +
  theme_minimal(base_size = 18) +
  scale_color_manual(values=c("#1E88E5","#E53935")) +
  labs(title = "Análisis de Componentes Principales (PCA)")

print(p)
dev.off()

# =====================================================================
# 9. HEATMAP
# =====================================================================

M <- cor(vars)
hc <- hclust(dist(M))
M_ord <- M[hc$order, hc$order]
M_melt <- melt(M_ord)
colnames(M_melt) <- c("Var1", "Var2", "Cor")

pdf("plots/lasso/heatmap_wdbc.pdf", width=14, height=12)

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
# 10. GENERAR LOG DE RESULTADOS (summary, AIC, pseudo-R2)
# =====================================================================

sink("resultados-lasso.log")
  
cat("==========================================================\n")
cat(" ANÁLISIS DE REGRESIÓN LOGÍSTICA — WDBC (solo variables _mean)\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n\n")

cat("==========================================================\n")
cat(" COMPARACIÓN DE MODELOS POR AIC\n")
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
  cat(nombre, ":\n")
  print(pR2(modelos[[nombre]]))
  cat("\n")
}


cat("==========================================================\n")
cat(" MODELO LASSO — VARIABLES SELECCIONADAS\n")
cat("==========================================================\n\n")

cat("λ óptimo (lambda.min): ", lambda_min, "\n")
cat("λ 1-SE (lambda.1se): ", lambda_1se, "\n\n")

cat("Variables seleccionadas por LASSO (lambda.min):\n")
print(vars_lasso_min)
cat("\n\n")

cat("Coeficientes LASSO (lambda.min):\n")
print(coef_min)
cat("\n\n")

cat("Variables seleccionadas por LASSO (lambda.1se):\n")
print(vars_lasso_1se)
cat("\n\n")

cat("Coeficientes LASSO (lambda.1se):\n")
print(coef_1se)
cat("\n\n")

cat("==========================================================\n")
cat(" MODELO RIDGE — VARIABLES (lambda.min y 1-SE)\n")
cat("==========================================================\n\n")

cat("λ Ridge mínimo (lambda.min): ", ridge_lambda_min, "\n")
cat("λ Ridge 1-SE (lambda.1se): ", ridge_lambda_1se, "\n\n")

cat("Variables (ridge.lambda.min):\n")
print(vars_ridge_min)
cat("\nCoeficientes Ridge (lambda.min):\n")
print(coef_ridge_min)
cat("\n\n")

cat("Variables (ridge.lambda.1se):\n")
print(vars_ridge_1se)
cat("\nCoeficientes Ridge (lambda.1se):\n")
print(coef_ridge_1se)
cat("\n\n")



cat("==========================================================\n")
cat(" SUMMARYS DE LOS MODELOS\n")
cat("==========================================================\n\n")

for (nombre in names(modelos)) {
  cat("----------------------------------------------------------\n")
  cat(" ", nombre, "\n")
  cat("----------------------------------------------------------\n")
  print(summary(modelos[[nombre]]))
  cat("\n\n")
}

sink()
















