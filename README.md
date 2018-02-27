
<!-- README.md is generated from README.Rmd. Please edit that file -->
npi
===

> Access the U.S. National Provider Identifier Registry API

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![Travis build status](https://travis-ci.org/frankfarach/npi.svg?branch=master)](https://travis-ci.org/frankfarach/npi) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/frankfarach/npi?branch=master&svg=true)](https://ci.appveyor.com/project/frankfarach/npi) [![Coverage status](https://codecov.io/gh/frankfarach/npi/branch/master/graph/badge.svg)](https://codecov.io/github/frankfarach/npi?branch=master)

Provide access to the API for the U.S. National Provider Identifier (NPI) Registry Public Search provided by the Center for Medicare and Medicaid Services (CMS): <https://npiregistry.cms.hhs.gov/>.

Example
-------

Use `search_npi()` to search the public NPI Registry by the [available parameters](https://npiregistry.cms.hhs.gov/registry/help-api) and get the results as a complex data frame of vectors and data frames. A future release will return a simplified tidy data frame (tibble) to make the data easier to work with.

``` r
# Return the first 3 organizational provider names and NPIs
# for providers registered in the 98101 ZIP code:
res <- npi::search_npi(
  postal_code = "98101",
  enumeration_type = "NPI-2",
  address_purpose = "LOCATION",
  limit = 3
)

# Extract the organizational names and NPIs and bind in one data frame
org_names <- res$basic %>%
filter(status == "A") %>%
select(name)

npis <- res %>% select(number)

df <- bind_cols(org_names, npis)
df
#>                            name     number
#> 1 VIRGINIA MASON MEDICAL CENTER 1174527683
#> 2         CITY CHIROPRACTIC INC 1902880578
#> 3           BRYANT AND JUNGE PS 1588674808
```

Use `is_valid_npi()` to check whether a candidate number is a valid NPI number:

``` r
# Validate one-off NPIs
npi::is_valid_npi(1234567893)
#> [1] TRUE
npi::is_valid_npi(1234567898)
#> [1] FALSE

# Validate NPIs returned from registry
df %>% mutate(valid_npi = is_valid_npi(number))
#>                            name     number valid_npi
#> 1 VIRGINIA MASON MEDICAL CENTER 1174527683      TRUE
#> 2         CITY CHIROPRACTIC INC 1902880578      TRUE
#> 3           BRYANT AND JUNGE PS 1588674808      TRUE
```

Installation
------------

This package can be installed directly from this Github repo:

``` r
devtools::install_github("frankfarach/npi")
```

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

License
-------

MIT (c) [Frank Farach](https://github.com/frankfarach)
