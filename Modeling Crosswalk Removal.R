library(tidyverse)
library(sf)

# loads in data
all_crashes_df <- read_csv("all_crashes.csv") %>%
  mutate(collision_date = lubridate::mdy_hms(collisiondate))
# cleans time
all_crashes_df <- all_crashes_df %>%
  mutate(collision_hr = str_extract(collisiontime, "[0-9]{2}"),
         collision_min = str_extract(collisiontime, "[0-9]{2}$"),
         collision_date = lubridate::date(collisiondate))

all_crashes_sf <- all_crashes_df %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# filters to just our intersections
bbox <- st_bbox(c(xmin = -84.493340, ymin = 39.096533, xmax = -84.490958, ymax = 39.098398), crs = 4326)

# creates a fucntion to run the model for all variants
run_model <- function(date_threshold) {
  all_crashes_sf_filtered <- all_crashes_sf %>%
    st_filter(st_as_sfc(bbox)) %>%
    mutate(after_remove_xwalk = collision_date > ymd(date_threshold))
  
  crash_counts <- all_crashes_sf_filtered %>%
    st_drop_geometry %>%
    mutate(month = floor_date(collision_date, "month"),
           after_remove_xwalk = collision_date > ymd(date_threshold)) %>%
    group_by(month, after_remove_xwalk) %>%
    summarise(crash_count = n(), .groups = "drop") %>%
    arrange(month) %>%
    mutate(month_index = as.numeric(difftime(month, min(month), units = "weeks")) / 4.345)
  
  citywide_counts <- all_crashes_sf %>%
    st_drop_geometry() %>%
    mutate(month = floor_date(collision_date, "month")) %>%
    group_by(month) %>%
    summarise(city_crash_count = n(), .groups = "drop")
  
  crash_counts <- crash_counts %>%
    left_join(citywide_counts, by = "month")
  
  model <- glm(crash_count ~ after_remove_xwalk + month_index + log(city_crash_count),
               family = poisson(), data = crash_counts)
  
  return(summary(model))
}

after_remove_xwalk_earliest <- run_model("2022-06-01")
### OUTPUT:
# Call:
#   glm(formula = crash_count ~ after_remove_xwalk + month_index + 
#         log(city_crash_count), family = poisson(), data = crash_counts)
# 
# Coefficients:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)             2.3756789  0.0534207   44.47   <2e-16 ***
#   after_remove_xwalkTRUE  1.1462681  0.0167159   68.57   <2e-16 ***
#   month_index            -0.0138298  0.0001204 -114.89   <2e-16 ***
#   log(city_crash_count)   0.4692945  0.0054936   85.42   <2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# (Dispersion parameter for poisson family taken to be 1)
# 
# Null deviance: 117211  on 152  degrees of freedom
# Residual deviance:  97831  on 149  degrees of freedom
# AIC: 98918
# 
# Number of Fisher Scoring iterations: 8
# interpretation: exp(1.1462681) ~ 3.146, so ~ 215% increase in accidents after crosswalk removal
after_remove_xwalk_realistic <- run_model("2022-11-01")
### OUTPUT
# Call:
#   glm(formula = crash_count ~ after_remove_xwalk + month_index + 
#         log(city_crash_count), family = poisson(), data = crash_counts)
# 
# Coefficients:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)             2.303043   0.051037   45.12   <2e-16 ***
#   after_remove_xwalkTRUE  0.307073   0.016925   18.14   <2e-16 ***
#   month_index            -0.009407   0.000106  -88.72   <2e-16 ***
#   log(city_crash_count)   0.457938   0.005226   87.64   <2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# (Dispersion parameter for poisson family taken to be 1)
# 
# Null deviance: 117776  on 153  degrees of freedom
# Residual deviance: 102386  on 150  degrees of freedom
# AIC: 103478
# 
# Number of Fisher Scoring iterations: 8
# interpretation: exp(0.307073) ~ 1.360, so ~ 36% increase in accidents after crosswalk removal
after_remove_xwalk_latest <- run_model("2024-02-01")
### OUTPUT:
# Call:
#   glm(formula = crash_count ~ after_remove_xwalk + month_index + 
#         log(city_crash_count), family = poisson(), data = crash_counts)
# 
# Coefficients:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)             2.283e+00  5.083e-02   44.91   <2e-16 ***
#   after_remove_xwalkTRUE  4.970e-01  1.934e-02   25.71   <2e-16 ***
#   month_index            -9.247e-03  9.476e-05  -97.59   <2e-16 ***
#   log(city_crash_count)   4.595e-01  5.211e-03   88.19   <2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# (Dispersion parameter for poisson family taken to be 1)
# 
# Null deviance: 117211  on 152  degrees of freedom
# Residual deviance: 101997  on 149  degrees of freedom
# AIC: 103083
# 
# Number of Fisher Scoring iterations: 8
# interpretation: exp(4.970e-01) ~ 1.644, so ~ 65% increase in accidents after crosswalk removal
