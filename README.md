# Multi-level Nested Pie Chart for Flow Cytometry Data

A visualization tool for displaying expression of multiple markers using boolean gating in flow cytometry data.

## Overview

This R script creates multi-level nested pie charts to visualize:
- **Functions**: How many markers are expressed simultaneously
- **Inhibitory Receptors**: Which specific markers are expressed
- **Expression**: Expression levels of marker combinations

## Installation

### Required Packages

```r
install.packages("ggplot2")
install.packages("ggnewscale")
install.packages("dplyr")  # if working with multiple patient groups
install.packages("tidyr")  # required for data processing
```

### Load Libraries

```r
library(ggplot2)
library(ggnewscale)
library(dplyr)
library(tidyr)
```

## Usage

### Basic Example

For a simple visualization with pre-formatted data:

```r
# Load your data (see Data Format section below)
source("cytokine_pie_chart.R")

# The script will generate the nested pie chart
```

### Multiple Patient Groups

If you have data from multiple patient groups:

```r
# 1. Filter data for specific patient group
severe_1 <- all_data %>%
    dplyr::filter(timepoint == "1" & severity == "severe")

# 2. Summarize expression across patients
severe_1 <- severe_1 %>% 
    group_by(functions, inhibitory_receptors) %>%
    summarise(expression = sum(expression))

# 3. Use severe_1 as input to the visualization script
```

## Data Format

Your input data should be a data frame with three columns:

| Column | Type | Description |
|--------|------|-------------|
| `functions` | character/factor | Number of markers expressed (e.g., "1", "2", "3") |
| `inhibitory_receptors` | character | Marker names separated by "/" (e.g., "PD-1/TIGIT") |
| `expression` | numeric | Expression level values |

### Example Data Structure

```r
cytokine_expression <- data.frame(
    functions = c("1", "1", "2", "2", "3"),
    inhibitory_receptors = c("PD-1", "TIGIT", "PD-1/TIGIT", "PD-1/TIM3", "CTLA4/LAG3/PD-1"),
    expression = c(1, 1.5, 2, 4, 1)
)
```

## Customization

### Colors

Modify the `mainCol` vector to change the color scheme:

```r
mainCol <- c("#232023", "#696969", "#A9A9A9", "#D3D3D3", "grey95")
```

### Ring Width

Adjust the width of the outer label rings:

```r
labelsize <- 0.2  # Default value, increase for wider rings
```

## Output

The script generates a circular nested pie chart where:
- **Inner ring**: Shows the proportion of cells expressing different numbers of markers (colored by function level)
- **Outer rings**: Display which specific markers are expressed (one ring per unique marker)

## Example Dataset

The repository includes example data representing:
- 5 single-marker expressions
- 10 dual-marker combinations
- 10 triple-marker combinations
- 5 quadruple-marker combinations
- 1 quintuple-marker combination

## Contact

For questions or issues, please open an issue on GitHub.

## Acknowledgments

Built using:
- [ggplot2](https://ggplot2.tidyverse.org/)
- [ggnewscale](https://github.com/eliocamp/ggnewscale)

