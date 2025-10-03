# ============================================================================
# Multi-level Nested Pie Chart for Inhibitory Receptor Expression Data
# ============================================================================
# Visualizes expression of multiple inhibitory receptors using boolean gating
# - Functions: number of inhibitory receptors expressed simultaneously
# - Inhibitory receptors: specific receptors expressed (PD-1, TIGIT, etc.)
# - Expression: expression levels
# ============================================================================

# Load required packages ----
library(ggplot2)
library(ggnewscale)
library(dplyr)
library(tidyr)

# Example Data ----
# Replace this with your own data in the same format
inhibitory_expression <- structure(
  list(
    functions = c(
      "1", "1", "1", "1", "1",
      "2", "2", "2", "2", "2", "2", "2", "2", "2", "2",
      "3", "3", "3", "3", "3", "3", "3", "3", "3", "3",
      "4", "4", "4", "4", "4",
      "5"
    ),
    inhibitory_receptors = c(
      "PD-1", "TIGIT", "TIM3", "CTLA4", "LAG3",
      "PD-1/TIGIT", "PD-1/TIM3", "TIGIT/TIM3", "LAG3/TIGIT", "CTLA4/LAG3",
      "LAG3/TIM3", "LAG3/PD-1", "CTLA4/TIM3", "CTLA4/PD-1", "CTLA4/TIGIT",
      "CTLA4/LAG3/PD-1", "CTLA4/LAG3/TIGIT", "CTLA4/LAG3/TIM3", "CTLA4/PD-1/TIGIT",
      "CTLA4/PD-1/TIM3", "CTLA4/TIGIT/TIM3", "LAG3/PD-1/TIM3", "LAG3/TIGIT/TIM3",
      "LAG3/PD-1/TIGIT", "PD-1/TIGIT/TIM3",
      "CTLA4/LAG3/PD-1/TIGIT", "CTLA4/LAG3/PD-1/TIM3",
      "CTLA4/LAG3/TIGIT/TIM3", "CTLA4/PD-1/TIGIT/TIM3", "LAG3/PD-1/TIGIT/TIM3",
      "CTLA4/LAG3/PD-1/TIGIT/TIM3"
    ),
    expression = c(
      1, 1.5, 2, 1, 2.5,
      2, 4, 0.75, 0.75, 0.5, 5.5, 12, 3, 4, 5,
      1, 2, 3, 5, 7, 1.5, 2, 3, 4, 2,
      1.5, 1, 0.5, 0.5, 0.15,
      1
    )
  ),
  class = c("tbl_df", "tbl", "data.frame"),
  row.names = c(NA, -31L)
)

# ============================================================================
# OPTIONAL: Filter and Summarize for Multiple Patient Groups
# ============================================================================
# Uncomment and modify if you have multiple patient groups
#
# # Step 1: Filter data for specific patient group
# severe_1 <- all_data %>%
#     dplyr::filter(timepoint == "1" & severity == "severe")
#
# # Step 2: Summarize expression across patients
# inhibitory_expression <- severe_1 %>%
#     group_by(functions, inhibitory_receptors) %>%
#     summarise(expression = sum(expression), .groups = "drop")
# ============================================================================

# Data Processing ----
# Pre-compute segment locations and split receptor labels
inhibitory_expression <- inhibitory_expression %>%
  dplyr::mutate(
    # Cumulative positions for pie segments
    max = cumsum(expression),
    min = cumsum(expression) - expression,
    # Split receptor names into individual labels
    labels = strsplit(inhibitory_receptors, "/")
  )

# Expand data for outer rings (one row per receptor)
extralabels <- tidyr::unnest(inhibitory_expression, labels)

# Visualization Settings ----
# Color scheme for function levels (inner ring)
mainCol <- c("#232023", "#696969", "#A9A9A9", "#D3D3D3", "grey95")

# Width of each outer receptor ring
labelsize <- 0.2

# Create Plot ----
plot <- ggplot(inhibitory_expression, aes(ymin = min, ymax = max)) +
  # Inner ring: colored by number of functions (co-expressed receptors)
  geom_rect(
    aes(xmin = 0, xmax = 1, fill = factor(functions))
  ) +
  scale_fill_manual(
    values = mainCol,
    name = "Functions"
  ) +
  # Enable second fill scale for outer rings
  new_scale_fill() +
  # Outer rings: colored by individual inhibitory receptors
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
  coord_polar(theta = "y")

# Display plot
print(plot)

# Save plot (optional) ----
# Uncomment to save
# ggsave("inhibitory_receptor_pie_chart.png", plot, width = 10, height = 8, dpi = 300)