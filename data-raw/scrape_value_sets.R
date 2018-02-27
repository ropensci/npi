# Load Packages -----------------------------------------------------------

library(rvest)
library(magrittr)
library(tidyr)
library(readr)

# Scrape country codes ----------------------------------------------------

countries <- "https://npiregistry.cms.hhs.gov/registry/API-Country-Abbr" %>%
  read_html() %>%
  html_nodes("table") %>%
  .[1] %>%
  html_table(trim = TRUE) %>%
  .[[1]] %>%
  as_tibble()

# Fix mangled names
names(countries) <- c("country_abbr", "country_name")

# R thinks Namibia's ISO code of "NA" is NA (missing); this fixes it
countries$country_abbr <-
  countries$country_abbr %>%
  replace_na("NA")

# Scrape state codes ------------------------------------------------------

states <- "https://npiregistry.cms.hhs.gov/registry/API-State-Abbr" %>%
  read_html() %>%
  html_nodes("table") %>%
  .[1] %>%
  html_table(trim = TRUE) %>%
  .[[1]] %>%
  as_tibble()

names(states) <- c("state_abbr", "state_name")

# Scrape Healthcare Provider Taxonomy -------------------------------------

provider_taxonomy <-
  "http://nucc.org/images/stories/CSV/nucc_taxonomy_180.csv" %>%
  read_csv(
    skip = 1,
    col_names = c(
      "code",
      "grouping",
      "classification",
      "specialization",
      "definition",
      "notes"
    ),
    col_types = "cccccc"
  )


# Make data available for internal package use ----------------------------

usethis::use_data(
  countries, states, provider_taxonomy,
  internal = TRUE, overwrite = TRUE
)
