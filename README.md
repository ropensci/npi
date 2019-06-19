
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

Use R to access the U.S. National Provider Identifier (NPI) Registry API
(v2.1) by the Center for Medicare and Medicaid Services (CMS):
<https://npiregistry.cms.hhs.gov/>. Obtain rich administrative data
linked to a specific individual or organizational healthcare provider,
or perform advanced searches based on provider name, location, type of
service, credentials, and many other attributes. `npi` provides
convenience functions for data extraction so you can spend less time
wrangling data and more time putting data to work.

## Installation

Install `npi` directly from Github using the `devtools` package:

``` r
devtools::install_github("frankfarach/npi")
library(npi)
```

## Usage

`npi` exports three functions:

  - `search_npi()`: Search the NPI Registry and return the response as a
    [tibble](http://tibble.tidyverse.org/) with high-cardinality data
    organized into list columns.
  - `get_list_col()`: Unnest a list column from a `search_npi()` result,
    joined by NPI number.
  - `is_valid_npi()`: Check the validity of one or more NPI numbers
    using the official [NPI enumeration
    standard](https://www.cms.gov/Regulations-and-Guidance/Administrative-Simplification/NationalProvIdentStand/Downloads/NPIcheckdigit.pdf).

### Search the registry

`search_npi()` exposes nearly all of the NPPES API’s [search
parameters](https://npiregistry.cms.hhs.gov/registry/help-api). Let’s
say you wanted to find up to 5 organizational providers with primary
locations in New York City. That’s one line:

``` r
nyc <- search_npi(city = "New York City", provider_type = 2, limit = 5)
```

``` r
nyc
#> # A tibble: 5 x 11
#>      npi provider_type basic other_names identifiers taxonomies addresses
#> *  <int> <chr>         <lis> <list>      <list>      <list>     <list>   
#> 1 1.35e9 Organization  <tib… <tibble [0… <tibble [1… <tibble [… <tibble …
#> 2 1.59e9 Organization  <tib… <tibble [0… <tibble [3… <tibble [… <tibble …
#> 3 1.75e9 Organization  <tib… <tibble [0… <tibble [0… <tibble [… <tibble …
#> 4 1.02e9 Organization  <tib… <tibble [1… <tibble [2… <tibble [… <tibble …
#> 5 1.05e9 Organization  <tib… <tibble [0… <tibble [8… <tibble [… <tibble …
#> # … with 4 more variables: practice_locations <list>, endpoints <list>,
#> #   created_date <dttm>, last_updated_date <dttm>
```

The full search results have four regular vector columns, `npi`,
`provider_type`, `created_date`, and `last_updated_date` and seven list
columns. Each list column is a collection of related data:

  - `basic`: Basic profile information about the provider
  - `other_names`: Other names used by the provider
  - `identifiers`: Other provider identifiers and credential information
  - `taxonomies`: Service classification and license information
  - `addresses`: Location and mailing address information
  - `practice_locations`: Provider’s practice locations
  - `endpoints`: Details about provider’s endpoints for health
    information exchange

Although the resulting tibble is somewhat complex, `npi` has you covered
with convenience functions to summarize and extract just the data you
need.

## Working with search results

Run `summary()` on your results to see what you’ve got:

``` r
summary(nyc)
#> # A tibble: 5 x 6
#>       npi name    provider_type primary_practice_a… phone primary_taxonomy 
#>     <int> <chr>   <chr>         <chr>               <chr> <chr>            
#> 1  1.35e9 NICULA… Organization  10 EAST 38TH STREE… 212-… Internal Medicin…
#> 2  1.59e9 UNDERN… Organization  160 E 34TH ST 4TH … 212-… Durable Medical …
#> 3  1.75e9 NEURO-… Organization  635 WEST 165 ST, N… 212-… Ophthalmology    
#> 4  1.02e9 MEDICA… Organization  250 EAST HOUSTON S… 212-… Podiatrist       
#> 5  1.05e9 METROP… Organization  2578 HEMPSTEAD TUR… 516-… Urology
```

Use `get_list_col()` to extract and unnest data by list column while
preserving its relationship with NPI:

``` r
# Get the `basic` list column from `nyc` using npi as the key
basic <- get_list_col(df = nyc, list_col = basic, key = npi)
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

# Get the `taxonomies` list column joined to NPI
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
