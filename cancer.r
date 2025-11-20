packages <- c(
  "ggplot2", "gclus", "corrplot", "pscl", "broom",
  "reshape2", "dplyr", "tidyr", "GGally"
)
#install.packages("stringi", type = "source")
install.packages(setdiff(packages, rownames(installed.packages())))
lapply(packages, library, character.only = TRUE)

df <- read.csv("breast_cancer_wisconsin_diagnostic.csv")

# Eliminar columnas inútiles
df <- df[, colSums(is.na(df)) < nrow(df)]
df <- df[, sapply(df, function(x) length(unique(x)) > 1)]

# Variable objetivo como factor
df$diagnosis <- factor(df$diagnosis,
                       levels = c("B","M"),
                       labels = c("Benigno","Maligno"))

# Modelo completo
modelo <- glm(diagnosis ~ ., data=df, family=binomial)

# Modelo clínico
modelo_clinico <- glm(
  diagnosis ~ radius_mean + perimeter_mean + area_mean +
               concavity_mean + concave.points_mean,
  data=df, family=binomial
)

# Variables suaves / textura / forma
modelo_estilo <- glm(
  diagnosis ~ texture_mean + smoothness_mean +
               compactness_mean + symmetry_mean,
  data=df, family=binomial
)

# Morfológicas avanzadas
modelo_morfologico <- glm(
  diagnosis ~ radius_mean + radius_worst +
               concave.points_mean + concave.points_worst,
  data=df, family=binomial
)

# Modelo compacto
modelo_compacto <- glm(
  diagnosis ~ radius_mean + concavity_mean,
  data=df, family=binomial
)

# Comparación por AIC
AIC(modelo, modelo_clinico, modelo_estilo,
    modelo_morfologico, modelo_compacto)

pR2(modelo)
pR2(modelo_clinico)
pR2(modelo_estilo)
pR2(modelo_morfologico)
pR2(modelo_compacto)

pdf("diagnosticos_modelos.pdf", width = 10, height = 10)
modelos <- list(
  "Modelo completo"      = modelo,
  "Modelo clínico"       = modelo_clinico,
  "Modelo estilo"        = modelo_estilo,
  "Modelo morfológico"   = modelo_morfologico,
  "Modelo compacto"      = modelo_compacto
)

for (nombre in names(modelos)) {

  # página separadora
  plot.new()
  text(0.5, 0.5, nombre, cex = 2, font = 2)

  # gráficos de diagnóstico
  plot(modelos[[nombre]])
}

dev.off()

vars <- df[, setdiff(names(df), "diagnosis")]

corr_mat <- abs(cor(vars))
corr_colors <- dmat.color(corr_mat)
order_vars <- order.single(corr_mat)

pdf("pairs_wdbc.pdf", width = 20, height = 20)

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


pdf("cpairs_wdbc.pdf", width = 20, height = 20)

par(cex = 0.6)        # escala general
par(cex.axis = 0.5)   # tamaño de las etiquetas de ejes
par(mar = c(5,5,3,1)) # márgenes más grandes

cpairs(
  vars,
  order_vars,
  panel.colors = corr_colors,
  gap = 0.5,
  main = "Interacción entre variables predictoras (WDBC)"
)

dev.off()

vars <- df[, setdiff(names(df), "diagnosis")]
pca <- prcomp(vars, scale.=TRUE)

scores <- as.data.frame(pca$x[, 1:2])
scores$diagnosis <- df$diagnosis

pdf("pca_scores.pdf", width=8, height=6)
ggplot(scores, aes(PC1, PC2, color=diagnosis)) +
  geom_point(alpha=0.6, size=2) +
  stat_ellipse(level=0.95, linetype="solid") +
  theme_minimal(base_size = 18) +
  scale_color_manual(values=c("#1E88E5","#E53935"))

dev.off()

# Extraer rotación para variables
rot <- as.data.frame(pca$rotation[, 1:2])
rot$varname <- rownames(rot)

# 1. Matriz de correlación
M <- cor(vars)

# 2. Ordenamiento jerárquico para mejor agrupación visual
hc <- hclust(dist(M))
M_ord <- M[hc$order, hc$order]

# 3. Convertir a formato largo para ggplot
M_melt <- melt(M_ord)
colnames(M_melt) <- c("Var1", "Var2", "Cor")

# 4. Exportar como PDF vectorial (zoom infinito)
pdf("heatmap_wdbc.pdf", width=14, height=12)

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

