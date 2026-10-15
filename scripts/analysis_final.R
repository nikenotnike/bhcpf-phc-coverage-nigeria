# ============================================================
# BHCPF Disbursement, IGR and PHC Doctor Coverage in Nigeria
# Author: Shekinah Nikè Adaramola
# Date: 12 October 2026
# ============================================================

#Load packages

library(tidyverse)
library(stringr)
library(dplyr)
library(patchwork)
library(tidyr)
library(ggplot2)

#Load datasets

analysis_combined <- readRDS("data/analysis_combined_clean.rds")

#Check and clean the data
# structure and dimensions
glimpse(analysis_combined)
dim(analysis_combined)
names(analysis_combined)

#check for missing values
colSums(is.na(analysis_combined))

#check for duplicated states
sum(duplicated(analysis_combined$state))

#summary of analysis variable
summary(analysis_combined[, c("doctor_density_per_10000", 
                              "bhcpf_per_capita", 
                              "igr_per_capita",
                              "phc_doctor_coverage",
                              "population")])

#All data already merged into analysis_combined in previous script
#Analysis variables already created

#Generate descriptive Analysis

descriptive_table <- analysis_combined %>%
  summarise(
    across(
      c(phc_doctor_coverage,
        bhcpf_per_capita,
        igr_per_capita,
        doctor_density_per_10000,
        population),
      list(
        Mean   = ~mean(.x, na.rm = TRUE),
        Median = ~median(.x, na.rm = TRUE),
        SD     = ~sd(.x, na.rm = TRUE),
        Min    = ~min(.x, na.rm = TRUE),
        Max    = ~max(.x, na.rm = TRUE)
      ),
      .names = "{.col}__{.fn}"
    )
  ) %>%
  pivot_longer(everything(),
               names_to = c("variable", "statistic"),
               names_sep = "__") %>%
  pivot_wider(names_from = statistic, values_from = value)

#Analysis by geographical zone
zonal_distribution <- analysis_combined %>%
  group_by(geopolitical_zone) %>%
  summarise(
    n_states = n(),
    mean_phc_coverage = mean(phc_doctor_coverage, na.rm = TRUE),
    mean_bhcpf = mean(bhcpf_per_capita, na.rm = TRUE),
    mean_igr = mean(igr_per_capita, na.rm = TRUE)
  )

#Regression analyses
# Primary: does BHCPF predict PHC doctor coverage?

model_primary <- lm(phc_doctor_coverage ~ bhcpf_per_capita + igr_per_capita, 
                    data = analysis_combined)
summary(model_primary)

# Secondary: does BHCPF predict overall doctor density?

model_secondary <- lm(doctor_density_per_10000 ~ bhcpf_per_capita + igr_per_capita,
                      data = analysis_combined)
summary(model_secondary)

#Figures

Fig_1_doctor_density_by_state <- ggplot(
  analysis_combined,
  aes(
    x =  reorder(state, doctor_density_per_10000),
    y = doctor_density_per_10000,
    colour = geopolitical_zone)) +
  geom_col()+
  coord_flip() +
  labs(
    title = "Medical Doctors Across Nigerian States",
    x = NULL,
    y = "Medical Doctors per 10,000 population"
  )

Fig_2_doctor_density_boxplot <- ggplot(analysis_combined, 
                                       aes(x = geopolitical_zone,
                                           y = doctor_density_per_10000)) +
  geom_boxplot() +
  labs(
    title = "Medical Doctor Density by Geopolitical Zone",
    x = "Geopolitical zone",
    y = "Medical Doctors per 10,000 population"
  )

Fig_3_bhcpf_to_doctor_scatterplot <- ggplot(analysis_combined,
                                            aes(
                                              x = bhcpf_per_capita,
                                              y = doctor_density_per_10000,
                                              colour = geopolitical_zone)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(
    aes (group = 1),
    method = "lm",
    se = TRUE,
    colour = "black") +
  labs(
    title = "BHCPF Disbursement per Capita and Medical Doctor Density",
    subtitle = "Association across Nigerian states",
    x = "BHCPF Disbursement per Capita (₦)",
    y = "Medical Doctors per 10,000 Population",
    colour = "Geopolitical Zone"
  ) +
  theme_minimal()

# Panel A: BHCPF vs PHC doctor coverage
p1 <- ggplot(analysis_combined, aes(x = bhcpf_per_capita, y = phc_doctor_coverage)) +
  geom_point(size = 3, color = "#2E86AB", alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "#A23B72", fill = "#A23B72", alpha = 0.2) +
  labs(
    title = "A. BHCPF per capita",
    x = "BHCPF Disbursement per Capita (₦)",
    y = "PHC Doctor Coverage"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    panel.grid.minor = element_blank()
  )


# Panel B: IGR vs PHC doctor coverage
p2 <- ggplot(analysis_combined, aes(x = igr_per_capita, y = phc_doctor_coverage)) +
  geom_point(size = 3, color = "#2E86AB", alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "#A23B72", fill = "#A23B72", alpha = 0.2) +
  labs(
    title = "B. Internally Generated Revenue per capita",
    x = "IGR per Capita (₦)",
    y = "PHC Doctor Coverage"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    panel.grid.minor = element_blank()
  )

# Combine side by side
combined_plot <- p1 + p2 +
  plot_annotation(
    title = "Association between health financing and PHC doctor coverage across Nigerian states",
    subtitle = "n = 27 states. Shaded bands represent 95% confidence intervals.",
    theme = theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 11, color = "gray40")
    )
  )

# Save outputs

write.csv(descriptive_table, "descriptive_table.csv", row.names = FALSE)
write.csv(zonal_distribution, "zonal_distribution.csv", row.names = FALSE)

sink("model_results.txt")
cat("=== PRIMARY MODEL: PHC Doctor Coverage ===\n\n")
print(summary(model_primary))
cat("\n\n=== SECONDARY MODEL: Total Doctor Density ===\n\n")
print(summary(model_secondary))
sink()

getwd()
list.files()

dir.create("figures")

# Figure 1: Primary — BHCPF + IGR vs PHC coverage
ggsave("figures/figure1_phc_coverage.png", combined_plot,
       width = 12, height = 5.5, dpi = 300)

# Figure 2: Secondary — BHCPF vs total doctor density
ggsave("figures/figure2_doctor_density_scatter.png", Fig_3_bhcpf_to_doctor_scatterplot,
       width = 8, height = 5.5, dpi = 300)

# Figure 3: Descriptive — boxplot of doctor density
ggsave("figures/figure3_doctor_density_boxplot.png", Fig_2_doctor_density_boxplot,
       width = 8, height = 5.5, dpi = 300)

# Figure 4: Descriptive — doctor density by state
ggsave("figures/figure4_doctor_density_by_state.png", Fig_1_doctor_density_by_state,
       width = 10, height = 6, dpi = 300)

