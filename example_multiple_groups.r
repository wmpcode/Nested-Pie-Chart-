# ============================================================================
# Example: Processing Multiple Patient Groups
# ============================================================================
# This script demonstrates how to filter and visualize inhibitory receptor
# expression data from multiple patient groups (e.g., different timepoints, 
# severity levels, treatments)
# ============================================================================

library(dplyr)
library(ggplot2)
library(ggnewscale)
library(tidyr)

# Example dataset with multiple patient groups ----
# Replace this with your actual data
all_data <- data.frame(
  patient_id = rep(1:5, each = 6),
  timepoint = rep(c("1", "2"), each = 15),
  severity = rep(c("severe", "moderate", "severe"), each = 10),
  functions = rep(c("1", "1", "2", "2", "3", "3"), 5),
  inhibitory_receptors = rep(c("PD-1", "TIGIT", "PD-1/TIGIT", "LAG3/TIGIT", 
                               "CTLA4/LAG3/PD-1", "PD-1/TIGIT/TIM3"), 5),
  expression = runif(30, 0.5, 5)
)

# ============================================================================
# Method 1: Filter and summarize a single group
# ============================================================================

# Filter for severe patients at timepoint 1
severe_1 <- all_data %>%
  dplyr::filter(timepoint == "1" & severity == "severe")

# Summarize expression across patients in this group
severe_1_summary <- severe_1 %>%
  group_by(functions, inhibitory_receptors) %>%
  summarise(expression = sum(expression), .groups = "drop")

# Create visualization for this group
# (Use the main visualization code from inhibitory_receptor_pie_chart.R)

# ============================================================================
# Method 2: Create plots for multiple groups in a loop
# ============================================================================

# Define groups to analyze
groups <- list(
  list(timepoint = "1", severity = "severe", name = "Severe_T1"),
  list(timepoint = "1", severity = "moderate", name = "Moderate_T1"),
  list(timepoint = "2", severity = "severe", name = "Severe_T2")
)

# Function to create plot for a group
create_group_plot <- function(data, tp, sev, plot_name) {
  
  # Filter and summarize
  group_data <- data %>%
    dplyr::filter(timepoint == tp & severity == sev) %>%
    group_by(functions, inhibitory_receptors) %>%
    summarise(expression = sum(expression), .groups = "drop") %>%
    mutate(
      max = cumsum(expression),
      min = cumsum(expression) - expression,
      labels = strsplit(inhibitory_receptors, "/")
    )
  
  # Expand for outer rings
  extralabels <- tidyr::unnest(group_data, labels)
  
  # Color scheme
  mainCol <- c("#232023", "#696969", "#A9A9A9", "#D3D3D3", "grey95")
  labelsize <- 0.2
  
  # Create plot
  p <- ggplot(group_data, aes(ymin = min, ymax = max)) +
    geom_rect(aes(xmin = 0, xmax = 1, fill = factor(functions))) +
    scale_fill_manual(values = mainCol, name = "Functions") +
    new_scale_fill() +
    geom_rect(
      aes(
        xmin = match(labels, unique(labels)) * labelsize + 1.05 - labelsize,
        xmax = after_stat(xmin + labelsize * 0.75),
        fill = labels
      ),
      data = extralabels
    ) +
    scale_fill_discrete(name = "Receptors") +
    theme_void() +
    coord_polar(theta = "y") +
    ggtitle(plot_name)
  
  return(p)
}

# Generate plots for all groups
plots <- lapply(groups, function(g) {
  create_group_plot(all_data, g$timepoint, g$severity, g$name)
})

# Display plots
for (p in plots) {
  print(p)
}

# Save plots
# for (i in seq_along(plots)) {
#   ggsave(
#     filename = paste0(groups[[i]]$name, "_inhibitory_receptor_chart.png"),
#     plot = plots[[i]],
#     width = 10,
#     height = 8,
#     dpi = 300
#   )
# }

# ============================================================================
# Method 3: Compare groups side-by-side
# ============================================================================

library(patchwork)  # install if needed: install.packages("patchwork")

# Create a combined plot
combined_plot <- plots[[1]] + plots[[2]] + plots[[3]] +
  plot_layout(ncol = 3)

print(combined_plot)

# Save combined plot
# ggsave("combined_groups.png", combined_plot, width = 24, height = 8, dpi = 300)