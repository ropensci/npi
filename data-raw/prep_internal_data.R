# Load Packages -----------------------------------------------------------

library(rvest)
library(magrittr)
library(tidyr)
library(readr)
library(tibble)

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


# NPPES Code Table Values -------------------------------------------------
# Source: Data Dissemination Public File - Code Values
# Updated: July 10, 2013
# Effective Date: Aug, 2013

entity_type_codes <- tribble(
  ~code, ~desc,
  1, "Individual",
  2, "Organization"
)

# Used for sole proprietor, subart, and primary taxonomy codes
ynx_codes <- tribble(
  ~code, ~desc,
  "X", "Not Answered",
  "Y", "Yes",
  "N", "No"
)

gender_codes <- tribble(
  ~code, ~desc,
  "M", "Male",
  "F", "Female"
)

deactivation_reason_codes <- tribble(
  ~code, ~desc,
  "DT", "Death",
  "DB", "Disbandment",
  "FR", "Fraud",
  "OT", "Other"
)

other_provider_name_type_codes <- tribble(
  ~code, ~desc, ~entity_name_type_code,
  1, "Former Name", "I",
  2, "Professional Name", "I",
  3, "Doing Business As", "O",
  4, "Former Legal Business Name", "O",
  5, "Other Name", "B"
)

name_prefix_codes <- tribble(
  ~code, ~desc,
  "Ms.", "Ms..",
  "Mr.", "Mr.",
  "Miss", "Miss",
  "Dr.", "Dr.",
  "Prof.", "Prof."
)

name_suffix_codes <- tribble(
  ~code, ~desc,
  "Jr.", "Jr.",
  "Sr.", "Sr.",
  "I", "I",
  "II", "II",
  "III", "III",
  "IV", "IV",
  "V", "V",
  "VI", "VI",
  "VII", "VII",
  "VIII", "VIII",
  "IX", "IX",
  "X", "X"
)

other_provider_identifier_issuer_codes <- tribble(
  ~code, ~desc,
  "01", "OTHER",
  "02", "MEDICARE UPIN",
  "04", "MEDICARE ID-TYPE UNSPECIFIED",
  "05", "MEDICAID",
  "06", "MEDICARE OSCAR/CERTIFICATION",
  "07", "MEDICARE NSC",
  "08", "MEDICARE PIN"
)

group_taxonomy_codes <- tribble(
  ~code, ~desc,
  "193200000X", "Multi-Specialty Group",
  "193400000X", "Single Specialty Group"
)

# Bundle codes sets into a list for a tidier environment
nppes_code_sets <- list(
  entity_type_codes,
  ynx_codes,
  gender_codes,
  deactivation_reason_codes,
  other_provider_name_type_codes,
  name_prefix_codes,
  name_suffix_codes,
  other_provider_identifier_issuer_codes,
  group_taxonomy_codes
)

# TODO: Set names for list elements for easier extraction

# Set up internal test data -----------------------------------------------

# Get the first 5 records to keep the data set small
res <- search_npi(city = "New York City", state = "NY", limit = 5)

# Generate a data frame from the results object
res_df <- get_results(res)


# Make data available for internal package use ----------------------------

usethis::use_data(
  countries,
  states,
  provider_taxonomy,
  res,
  res_df,
  nppes_code_sets,
  internal = TRUE,
  overwrite = TRUE
)
