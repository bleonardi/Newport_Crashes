library(selenider)
library(tidyverse)

# Start session
session <- selenider_session()

open_url("http://crashinformationky.org/AdvancedSearch")
Sys.sleep(5)  # Allow initial JS to settle

message("🔹 Page loaded.")

# Step 1: Click "Add Property"
s(css = "div.eqjs-addrow.eqjs-qp-addrow a") %>% 
  elem_click()
Sys.sleep(1)

# Step 2: Click "City" property
s(xpath = "//div[contains(text(), 'City')]") %>%
  wait_until_visible(timeout = 5) %>%
  elem_click()
Sys.sleep(1)

# Step 3: Set "Newport" in city box
s(css = "a[title='[select value]']") %>% 
  elem_click()

s(css = "#searchBox") %>%
  elem_clear_value() %>%
  elem_send_keys("Newport")

# Select first search result
s(xpath = "//div[contains(@class, 'eqjs-suggestion-item')]") %>% 
  wait_until_visible(timeout = 3) %>%
  elem_click()

Sys.sleep(1)

# Step 4: Add "Collision date"
s(css = "div.eqjs-addrow.eqjs-qp-addrow a") %>% 
  elem_click()

s(xpath = "//div[contains(text(), 'Collision date')]") %>%
  wait_until_visible(timeout = 5) %>%
  elem_click()

Sys.sleep(1)

# Step 5: Choose "Between" operator
s(css = "div[id^='QueryPanel-cond-'] .eqjs-qp-operelement a") %>% 
  elem_click()

s(xpath = "//div[contains(text(), 'Between')]") %>%
  wait_until_visible(timeout = 5) %>%
  elem_click()

Sys.sleep(1)

# Loop through years
for (yr in 2010:2024) {
  start_date <- sprintf("01/01/%d", yr)
  end_date <- sprintf("12/31/%d", yr)
  message(glue::glue("📅 Running search for year {yr}"))
  
  # Step 6: Set start date
  s(xpath = "//div[contains(@id, 'cond') and contains(@class, 'eqjs-qp-condrow')]//a[contains(@class, 'eqjs-datepicker')][1]") %>%
    elem_click()
  
  s(css = "input.eqjs-datepicker-input") %>%
    wait_until_visible(timeout = 3) %>%
    elem_clear_value() %>%
    elem_send_keys(start_date)
  
  # Step 7: Set end date
  s(xpath = "//div[contains(@id, 'cond') and contains(@class, 'eqjs-qp-condrow')]//a[contains(@class, 'eqjs-datepicker')][2]") %>%
    elem_click()
  
  s(css = "input.eqjs-datepicker-input") %>%
    wait_until_visible(timeout = 3) %>%
    elem_clear_value() %>%
    elem_send_keys(end_date)
  
  # Step 8: Run query
  s(xpath = "//*[@id='ExecuteQuery']") %>%
    wait_until_visible(timeout = 5) %>%
    elem_click()
  Sys.sleep(8)
  
  # Step 9: Click Export
  s(xpath = "//ul[contains(@class, 'eqjs-menu')]//li/a[contains(text(), 'Export')]") %>%
    wait_until_visible(timeout = 5) %>%
    elem_click()
  Sys.sleep(2)
  
  # Step 10: Choose CSV
  s(xpath = "//div[contains(@class, 'eqjs-menu')]//div[contains(text(), 'CSV')]") %>%
    wait_until_visible(timeout = 3) %>%
    elem_click()
  Sys.sleep(1)
  
  # Step 11: Generate export
  s(xpath = "//a[contains(text(), 'Generate Export')]") %>%
    wait_until_visible(timeout = 5) %>%
    elem_click()
  
  message(glue::glue("✅ Export requested for {yr}"))
  Sys.sleep(5)
}