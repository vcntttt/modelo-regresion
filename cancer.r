packages <- c(
  "ggplot2", "gclus", "corrplot", "pscl", "broom",
  "reshape2", "dplyr", "tidyr", "GGally"
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
# 4. DIAGNÓSTICOS DE LOS MODELOS
# =====================================================================

pdf("plots/diagnosticos_modelos.pdf", width = 10, height = 10)

modelos <- list(
  "Modelo completo"      = modelo_completo,
  "Modelo A"             = modelo_A,
  "Modelo B"             = modelo_B,
  "Modelo C"             = modelo_C,
  "Modelo D"             = modelo_D
)

for (nombre in names(modelos)) {
  plot.new()
  text(0.5, 0.5, nombre, cex = 2, font = 2)
  plot(modelos[[nombre]])
}

dev.off()

# =====================================================================
# 5. PAIRS PLOT (GGPAIRS)
# =====================================================================

pdf("plots/pairs_wdbc.pdf", width = 20, height = 20)

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
# 6. CPAIRS (gclus)
# =====================================================================

corr_mat <- abs(cor(vars))
corr_colors <- dmat.color(corr_mat)
order_vars <- order.single(corr_mat)

pdf("plots/cpairs_wdbc.pdf", width = 20, height = 20)

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
# 7. PCA (scores)
# =====================================================================

pca <- prcomp(vars, scale.=TRUE)

scores <- as.data.frame(pca$x[, 1:2])
scores$diagnosis <- df$diagnosis

pdf("plots/pca_scores.pdf", width=8, height=6)

ggplot(scores, aes(PC1, PC2, color=diagnosis)) +
  geom_point(alpha=0.6, size=2) +
  stat_ellipse(level=0.95, linetype="solid") +
  theme_minimal(base_size = 18) +
  scale_color_manual(values=c("#1E88E5","#E53935"))

dev.off()

# =====================================================================
# 8. HEATMAP
# =====================================================================

M <- cor(vars)
hc <- hclust(dist(M))
M_ord <- M[hc$order, hc$order]
M_melt <- melt(M_ord)
colnames(M_melt) <- c("Var1", "Var2", "Cor")

pdf("plots/heatmap_wdbc.pdf", width=14, height=12)

ggplot(M_melt, aes(x = Var1, y = Var2, fill = Cor)) +
  geom_tile(color = "white", size = 0.1) +
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
    panel.border = element_rect(color="black", fill=NA, size=0.3)
  ) +
  labs(
    title = "Mapa de calor de correlaciones — WDBC",
    x = "",
    y = ""
  )

dev.off()

# =====================================================================
# 9. GENERAR LOG DE RESULTADOS (summary, AIC, pseudo-R2)
# =====================================================================

sink("resultados.log")
  
cat("==========================================================\n")
cat(" ANÁLISIS DE REGRESIÓN LOGÍSTICA — WDBC (solo variables _mean)\n")
cat(" Fecha de ejecución: ", as.character(Sys.time()), "\n")
cat("==========================================================\n\n\n")

cat("==========================================================\n")
cat(" COMPARACIÓN DE MODELOS POR AIC\n")
cat("==========================================================\n")
print(AIC(modelo_completo, modelo_A, modelo_B,
          modelo_C, modelo_D))
cat("\n\n")

cat("==========================================================\n")
cat(" PSEUDO-R² (McFadden, Cox–Snell, Nagelkerke)\n")
cat("==========================================================\n\n")

cat("Modelo completo:\n")
print(pR2(modelo_completo))
cat("\n\n")

cat("Modelo A:\n")
print(pR2(modelo_A))
cat("\n\n")

cat("Modelo B:\n")
print(pR2(modelo_B))
cat("\n\n")

cat("Modelo C:\n")
print(pR2(modelo_C))
cat("\n\n")

cat("Modelo D:\n")
print(pR2(modelo_D))
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

