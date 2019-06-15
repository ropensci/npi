
<!-- README.md is generated from README.Rmd. Please edit that file -->

# npi

> Access the U.S. National Provider Identifier Registry
API

[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build
status](https://travis-ci.org/frankfarach/npi.svg?branch=master)](https://travis-ci.org/frankfarach/npi)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/frankfarach/npi?branch=master&svg=true)](https://ci.appveyor.com/project/frankfarach/npi)
[![Coverage
status](https://codecov.io/gh/frankfarach/npi/branch/master/graph/badge.svg)](https://codecov.io/github/frankfarach/npi?branch=master)

Provide access to the free, public API for the U.S. National Provider
Identifier (NPI) Registry Public Search provided by the Center for
Medicare and Medicaid Services (CMS):
<https://npiregistry.cms.hhs.gov/>. The package is compatible with
version 2.1 of the API, which is the latest version available at the
time of this writing.

## Installation

This package can be installed directly from this Github repo:

``` r
devtools::install_github("frankfarach/npi")
library(npi)
```

## Usage

`npi` exports three functions:

  - `search_npi()`: Search the NPI Registry and return the response as
    tidy data.
  - `get_list_col()`: Extract and unnest a list column from a
    `search_npi()` result, joined by NPI number.
  - `is_valid_npi()`: Check the validity of one or more NPI numbers
    using the same algorithm used by the National Plan and Provider
    Enumeration System (NPPES).

### Searching

`search_npi()` is a thin wrapper around the NPI Registry’s API. It
exposes nearly all of the
[parameters](https://npiregistry.cms.hhs.gov/registry/help-api) made
available by the API and returns the results as a [tidy data
frame](http://tibble.tidyverse.org/), or tibble.

``` r
# Search for organizational providers in New York City, NY, 
# returning the first 5 records
nyc <- search_npi(city = "New York City", state = "NY", 
                  provider_type = 2, limit = 5)
```

``` r
nyc
#> # A tibble: 5 x 11
#>      npi provider_type basic other_names identifiers taxonomies addresses
#>    <int> <chr>         <lis> <list>      <list>      <list>     <list>   
#> 1 1.35e9 Organization  <tib… <tibble [0… <tibble [1… <tibble [… <tibble …
#> 2 1.59e9 Organization  <tib… <tibble [0… <tibble [3… <tibble [… <tibble …
#> 3 1.75e9 Organization  <tib… <tibble [0… <tibble [0… <tibble [… <tibble …
#> 4 1.02e9 Organization  <tib… <tibble [1… <tibble [2… <tibble [… <tibble …
#> 5 1.05e9 Organization  <tib… <tibble [0… <tibble [8… <tibble [… <tibble …
#> # … with 4 more variables: practice_locations <list>, endpoints <list>,
#> #   created_date <dttm>, last_updated_date <dttm>
```

### Controlling the maximum number of records returned

`search_npi()` allows you to optionally specify, via the `limit`
argument, an upper bound on the number of records returned:

``` r
# Returns up to 10 provider records
search_npi(city = "New York City", state = "NY")

# Returns up to 1200 provider records
search_npi(city = "New York City", state = "NY", limit = 1200)
```

If no value is supplied for `limit`, the API defaults to a maximum of 10
records. However, this behavior can be overriden by specifying a value
between 1 and 1200 to `limit`. Behind the scenes, `search_npi()` will
make multiple requests if necessary and bind the results together into a
tidy data frame.

## Working with search results

The data returned from `search_npi()` is organized according to its
relationship to the NPI column, which is the primary key for the table.
The columns `npi`, `provider_type`, `created_date`, and
`last_updated_date` are traditional atomic vector columns; everything
else is grouped into [list
columns](http://r4ds.had.co.nz/many-models.html#list-columns-1). Each
element of a list column is a list of tibbles.

There are seven such columns, which are always returned even if they
contain NULL records:

  - `basic`: Basic profile information about the provider
  - `other_names`: Other names used by the provider
  - `identifiers`: Miscellaneous provider identifiers and credential
    information linked to provider’s NPI
  - `taxonomies`: Service classification and license information
  - `addresses`: Location and mailing address information
  - `practice_locations`: Provider’s practice locations
  - `endpoints`: Details about provider’s endpoints for health
    information exchange

Any of these columns can be extracted as a tidy data frame using
`get_list_col()`:

``` r
# Get the basic list column joined
basic <- get_list_col(nyc, basic, npi)
basic
#> # A tibble: 5 x 14
#>      npi organization_na… organizational_… enumeration_date last_updated
#>    <int> <chr>            <chr>            <chr>            <chr>       
#> 1 1.35e9 NICULAE CIOBANU… NO               2005-12-06       2007-09-21  
#> 2 1.59e9 UNDERNEATH IT A… NO               2006-01-23       2007-07-08  
#> 3 1.75e9 NEURO-OPHTHALMI… NO               2006-03-17       2007-07-08  
#> 4 1.02e9 MEDICAL ARTS CE… NO               2006-05-16       2008-07-03  
#> 5 1.05e9 METROPOLITAN LI… NO               2006-07-02       2007-07-08  
#> # … with 9 more variables: status <chr>,
#> #   authorized_official_credential <chr>,
#> #   authorized_official_first_name <chr>,
#> #   authorized_official_last_name <chr>,
#> #   authorized_official_telephone_number <chr>,
#> #   authorized_official_title_or_position <chr>, name <chr>,
#> #   authorized_official_middle_name <chr>,
#> #   authorized_official_name_prefix <chr>

# Get the taxonomies list column joined to NPI
tax <- get_list_col(nyc, taxonomies, npi)
tax
#> # A tibble: 6 x 7
#>       npi code    desc           primary state license taxonomy_group      
#>     <int> <chr>   <chr>          <lgl>   <chr> <chr>   <chr>               
#> 1  1.35e9 207RH0… Internal Medi… FALSE   ""    ""      193400000X MULTIPLE…
#> 2  1.35e9 207RH0… Internal Medi… TRUE    NY    143167  193400000X MULTIPLE…
#> 3  1.59e9 332B00… Durable Medic… TRUE    ""    ""      <NA>                
#> 4  1.75e9 207W00… Ophthalmology  TRUE    NY    90955   193400000X SINGLE S…
#> 5  1.02e9 213E00… Podiatrist     TRUE    NY    N005813 193400000X SINGLE S…
#> 6  1.05e9 208800… Urology        TRUE    ""    ""      193400000X SINGLE S…
```

By repeating this process with other list columns, you can create
multiple tidy data frames and join them to make your own master tidy
data frame.

``` r
# Join basic and taxonomies by `npi`
left_join(basic, tax, by = "npi")
#> # A tibble: 6 x 20
#>      npi organization_na… organizational_… enumeration_date last_updated
#>    <int> <chr>            <chr>            <chr>            <chr>       
#> 1 1.35e9 NICULAE CIOBANU… NO               2005-12-06       2007-09-21  
#> 2 1.35e9 NICULAE CIOBANU… NO               2005-12-06       2007-09-21  
#> 3 1.59e9 UNDERNEATH IT A… NO               2006-01-23       2007-07-08  
#> 4 1.75e9 NEURO-OPHTHALMI… NO               2006-03-17       2007-07-08  
#> 5 1.02e9 MEDICAL ARTS CE… NO               2006-05-16       2008-07-03  
#> 6 1.05e9 METROPOLITAN LI… NO               2006-07-02       2007-07-08  
#> # … with 15 more variables: status <chr>,
#> #   authorized_official_credential <chr>,
#> #   authorized_official_first_name <chr>,
#> #   authorized_official_last_name <chr>,
#> #   authorized_official_telephone_number <chr>,
#> #   authorized_official_title_or_position <chr>, name <chr>,
#> #   authorized_official_middle_name <chr>,
#> #   authorized_official_name_prefix <chr>, code <chr>, desc <chr>,
#> #   primary <lgl>, state <chr>, license <chr>, taxonomy_group <chr>
```

### Validating NPIs

Use `is_valid_npi()` to check whether a candidate number is a valid NPI
number:

``` r
# Validate one-off NPIs
is_valid_npi(1234567893)
#> [1] TRUE
is_valid_npi(1234567898)
#> [1] FALSE
```

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

## License

MIT (c) [Frank Farach](https://github.com/frankfarach)
