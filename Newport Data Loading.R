library(tidyverse)

final_df <- NULL

# loops through each year
for (yr in 2010:2025) {
  # ensures empty at first
  incidents_df <- NULL
  for (f in list.files(path = paste0(yr, "/"), pattern = "*.txt")) {
    df <- suppressMessages(read_csv(paste0(yr, "/", f))) %>%
      rename_with(str_to_lower) %>%
      select(-starts_with("..."))
    # first file is starter
    if (is.null(incidents_df)) {
      print(paste0("First file, year ", yr, ":", f))
      incidents_df <- df
    } else {
      incidents_df <- left_join(incidents_df, df, by = "incidentid")
    }
  }
  # assign(paste0("incidents_", yr, "_df"), incidents_df)
  if(is.null(final_df)) {
    final_df <- incidents_df %>%
      mutate(street = as.character(street),
             testresults = as.character(testresults))
  } else {
    final_df <- final_df %>%
      add_row(incidents_df %>%
                mutate(street = as.character(street),
                       testresults = as.character(testresults)))
  }
}

