# Newport Crash Analysis: Modeling Infrastructure Changes

## Overview
An empirical evaluation of traffic safety in Newport, KY, specifically looking at how the removal of a crosswalk affected crash frequency. The project uses local incident data to test the hypothesis that infrastructure "simplification" for drivers increases risk for pedestrians.

## Key Data Science Skills
*   **Statistical Modeling:** Using **Poisson Regression** to model monthly crash counts.
*   **Web Scraping:** Extracting incident data from the Kentucky Transportation Cabinet (KYTC) public portal.
*   **Spatial Filtering:** Using bounding boxes and GIS tools to isolate intersection-level activity.
*   **Causal Inference:** Comparing crash rates "before" and "after" infrastructure modification.

## Tech Stack
*   **R (sf, tidyverse, lubridate):** Data cleaning and spatial statistics.
*   **Python:** Web scraping scripts for data acquisition.

## Data Sources
*   **KYTC Crash Portal:** [Kentucky Transportation Cabinet Advanced Search](http://crashinformationky.org/AdvancedSearch)
*   **US Census Bureau:** [ACS 5-Year Estimates](https://data.census.gov/)

## Data Source
Data is sourced from the [KYTC Crash Information Portal](http://crashinformationky.org/AdvancedSearch), filtered for the City of Newport and specific intersection coordinates.
