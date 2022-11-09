
<!-- README.md is generated from README.Rmd. Please edit that file -->

# npi <img src="man/figures/logo.png" align="right" height="139" />

> Access the U.S. National Provider Identifier Registry API

<!-- badges: start -->

[![Status at rOpenSci Software Peer
Review](https://badges.ropensci.org/505_status.svg)](https://github.com/ropensci/software-review/issues/505)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![R-CMD-check](https://github.com/ropensci/npi/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/npi/actions)
[![Codecov test
coverage](https://codecov.io/gh/ropensci/npi/branch/master/graph/badge.svg)](https://app.codecov.io/gh/ropensci/npi?branch=master)
[![DOI](https://zenodo.org/badge/122857655.svg)](https://zenodo.org/badge/latestdoi/122857655)
<!-- badges: end -->

Use R to access the U.S. National Provider Identifier (NPI) Registry API
(v2.1) by the Center for Medicare and Medicaid Services (CMS):
<https://npiregistry.cms.hhs.gov/>. Obtain rich administrative data
linked to a specific individual or organizational healthcare provider,
or perform advanced searches based on provider name, location, type of
service, credentials, and many other attributes. `npi` provides
convenience functions for data extraction so you can spend less time
wrangling data and more time putting data to work.

Analysts working with healthcare and public health data frequently need
to join data from multiple sources to answer their business or research
questions. Unfortunately, joining data in healthcare is hard because so
few entities have unique, consistent identifiers across organizational
boundaries. NPI numbers, however, do not suffer from these limitations,
as all U.S. providers meeting certain common criteria must have an NPI
number in order to be reimbursed for the services they provide. This
makes NPI numbers incredibly useful for joining multiple datasets by
provider, which is the primary motivation for developing this package.

## Installation

There are three ways to install the `npi` package:

1.  Install from CRAN:

``` r
install.packages("npi")
library(npi)
```

2.  Install from [R-universe](https://ropensci.org/r-universe/):

``` r
install.packages("npi", repos = "https://ropensci.r-universe.dev")
library(npi)
```

3.  Install from GitHub using the `devtools` package:

``` r
devtools::install_github("ropensci/npi")
library(npi)
```

## Usage

`npi` exports four functions, all of which match the pattern “npi\_\*“:

- `npi_search()`: Search the NPI Registry and return the response as a
  [tibble](https://tibble.tidyverse.org/) with high-cardinality data
  organized into list columns.
- `npi_summarize()`: A method for displaying a nice overview of results
  from `npi_search()`.
- `npi_flatten()`: A method for flattening one or more list columns from
  a search result, joined by NPI number.
- `npi_is_valid()`: Check the validity of one or more NPI numbers using
  the official NPI enumeration standard.

### Search the registry

`npi_search()` exposes nearly all of the NPPES API’s [search
parameters](https://npiregistry.cms.hhs.gov/registry/help-api). Let’s
say we wanted to find up to 10 providers with primary locations in New
York City:

``` r
nyc <- npi_search(city = "New York City")
```

``` r
# Your results may differ since the data in the NPPES database changes over time
nyc
#> # A tibble: 10 × 11
#>       npi enume…¹ basic    other_…² identi…³ taxono…⁴ addres…⁵ practi…⁶ endpoi…⁷
#>  *  <int> <chr>   <list>   <list>   <list>   <list>   <list>   <list>   <list>  
#>  1 1.19e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#>  2 1.31e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#>  3 1.64e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#>  4 1.35e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#>  5 1.56e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#>  6 1.79e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#>  7 1.56e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#>  8 1.96e9 Organi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#>  9 1.43e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#> 10 1.33e9 Indivi… <tibble> <tibble> <tibble> <tibble> <tibble> <tibble> <tibble>
#> # … with 2 more variables: created_date <dttm>, last_updated_date <dttm>, and
#> #   abbreviated variable names ¹​enumeration_type, ²​other_names, ³​identifiers,
#> #   ⁴​taxonomies, ⁵​addresses, ⁶​practice_locations, ⁷​endpoints
```

The full search results have four regular vector columns, `npi`,
`enumeration_type`, `created_date`, and `last_updated_date` and seven
list columns. Each list column is a collection of related data:

- `basic`: Basic profile information about the provider
- `other_names`: Other names used by the provider
- `identifiers`: Other provider identifiers and credential information
- `taxonomies`: Service classification and license information
- `addresses`: Location and mailing address information
- `practice_locations`: Provider’s practice locations
- `endpoints`: Details about provider’s endpoints for health information
  exchange

A full list of the possible fields within these list columns can be
found on the [NPPES API Help
page](https://npiregistry.cms.hhs.gov/registry/Json-Conversion-Field-Map).

If you’re comfortable [working with list
columns](https://r4ds.had.co.nz/many-models.html), this may be all you
need from the package. However, `npi` also provides functions that can
help you summarize and transform your search results.

## Working with search results

`npi` has two main helper functions for working with search results:
`npi_summarize()` and `npi_flatten()`.

### Summarizing results

Run `npi_summarize()` on your results to see a more human-readable
overview of your search results. Specifically, the function returns the
NPI number, provider’s name, enumeration type (individual or
organizational provider), primary address, phone number, and primary
taxonomy (area of practice):

``` r
npi_summarize(nyc)
#> # A tibble: 10 × 6
#>           npi name                                 enume…¹ prima…² phone prima…³
#>         <int> <chr>                                <chr>   <chr>   <chr> <chr>  
#>  1 1194276360 ALYSSA COWNAN                        Indivi… 5 E 98… 212-… Physic…
#>  2 1306849641 MARK MOHRMANN                        Indivi… 16 PAR… 212-… Orthop…
#>  3 1639173065 SAKSHI DUA                           Indivi… 10 E 1… 212-… Nurse …
#>  4 1346604592 SARAH LOWRY                          Indivi… 1335 D… 614-… Occupa…
#>  5 1558362566 AMY TIERSTEN                         Indivi… 1176 5… 212-… Psychi…
#>  6 1790786416 NOAH GOLDMAN                         Indivi… 140 BE… 973-… Intern…
#>  7 1558713628 ROBYN NOHLING                        Indivi… 9 HOPE… 781-… Nurse …
#>  8 1962983775 LENOX HILL MEDICAL ANESTHESIOLOGY, … Organi… 100 E … 212-… Intern…
#>  9 1427454529 YONGHONG TAN                         Indivi… 34 MAP… 203-… Obstet…
#> 10 1326403213 RAJEE KRAUSE                         Indivi… 12401 … 347-… Nurse …
#> # … with abbreviated variable names ¹​enumeration_type,
#> #   ²​primary_practice_address, ³​primary_taxonomy
```

### Flattening results

As seen above, the data frame returned by `npi_search()` has a nested
structure. Although all the data in a single row relates to one NPI,
each list column contains a list of one or more values corresponding to
the NPI for that row. For example, a provider’s NPI record may have
multiple associated addresses, phone numbers, taxonomies, and other
attributes, all of which live in the same row of the data frame.

Because nested structures can be a little tricky to work with, the `npi`
includes `npi_flatten()`, a function that transforms the data frame into
a flatter (i.e., unnested and merged) structure that’s easier to use.
`npi_flatten()` performs the following transformations:

- unnest the list columns
- prefix the name of each unnested column with the name of its original
  list column
- left-join the data together by NPI

`npi_flatten()` supports a variety of approaches to flattening the
results from `npi_search()`. One extreme is to flatten everything at
once:

``` r
npi_flatten(nyc)
#> # A tibble: 48 × 42
#>           npi basic_fi…¹ basic…² basic…³ basic…⁴ basic…⁵ basic…⁶ basic…⁷ basic…⁸
#>         <int> <chr>      <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>  
#>  1 1194276360 ALYSSA     COWNAN  PA      NO      F       2016-1… 2018-0… A      
#>  2 1194276360 ALYSSA     COWNAN  PA      NO      F       2016-1… 2018-0… A      
#>  3 1306849641 MARK       MOHRMA… MD      NO      M       2005-0… 2019-0… A      
#>  4 1306849641 MARK       MOHRMA… MD      NO      M       2005-0… 2019-0… A      
#>  5 1306849641 MARK       MOHRMA… MD      NO      M       2005-0… 2019-0… A      
#>  6 1306849641 MARK       MOHRMA… MD      NO      M       2005-0… 2019-0… A      
#>  7 1326403213 RAJEE      KRAUSE  AGPCNP… NO      F       2015-1… 2019-0… A      
#>  8 1326403213 RAJEE      KRAUSE  AGPCNP… NO      F       2015-1… 2019-0… A      
#>  9 1326403213 RAJEE      KRAUSE  AGPCNP… NO      F       2015-1… 2019-0… A      
#> 10 1326403213 RAJEE      KRAUSE  AGPCNP… NO      F       2015-1… 2019-0… A      
#> # … with 38 more rows, 33 more variables: basic_name <chr>,
#> #   basic_name_prefix <chr>, basic_middle_name <chr>,
#> #   basic_organization_name <chr>, basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>,
#> #   basic_authorized_official_last_name <chr>,
#> #   basic_authorized_official_middle_name <chr>, …
```

However, due to the number of fields and the large number of potential
combinations of values, this approach is best suited to small datasets.
More likely, you’ll want to flatten a small number of list columns from
the original data frame in one pass, repeating the process with other
list columns you want and merging after the fact. For example, to
flatten basic provider and provider taxonomy information, supply the
corresponding list columns as a vector of names to the `cols` argument:

``` r
# Flatten basic provider info and provider taxonomy, preserving the relationship
# of each to NPI number and discarding other list columns.
npi_flatten(nyc, cols = c("basic", "taxonomies"))
#> # A tibble: 20 × 26
#>           npi basic_fi…¹ basic…² basic…³ basic…⁴ basic…⁵ basic…⁶ basic…⁷ basic…⁸
#>         <int> <chr>      <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>  
#>  1 1194276360 ALYSSA     COWNAN  PA      NO      F       2016-1… 2018-0… A      
#>  2 1306849641 MARK       MOHRMA… MD      NO      M       2005-0… 2019-0… A      
#>  3 1306849641 MARK       MOHRMA… MD      NO      M       2005-0… 2019-0… A      
#>  4 1326403213 RAJEE      KRAUSE  AGPCNP… NO      F       2015-1… 2019-0… A      
#>  5 1326403213 RAJEE      KRAUSE  AGPCNP… NO      F       2015-1… 2019-0… A      
#>  6 1326403213 RAJEE      KRAUSE  AGPCNP… NO      F       2015-1… 2019-0… A      
#>  7 1346604592 SARAH      LOWRY   OTR/L   YES     F       2016-0… 2018-0… A      
#>  8 1346604592 SARAH      LOWRY   OTR/L   YES     F       2016-0… 2018-0… A      
#>  9 1427454529 YONGHONG   TAN     <NA>    NO      F       2014-1… 2018-1… A      
#> 10 1558362566 AMY        TIERST… M.D.    YES     F       2005-0… 2019-0… A      
#> 11 1558713628 ROBYN      NOHLING FNP-BC… YES     F       2016-0… 2018-0… A      
#> 12 1558713628 ROBYN      NOHLING FNP-BC… YES     F       2016-0… 2018-0… A      
#> 13 1558713628 ROBYN      NOHLING FNP-BC… YES     F       2016-0… 2018-0… A      
#> 14 1558713628 ROBYN      NOHLING FNP-BC… YES     F       2016-0… 2018-0… A      
#> 15 1558713628 ROBYN      NOHLING FNP-BC… YES     F       2016-0… 2018-0… A      
#> 16 1558713628 ROBYN      NOHLING FNP-BC… YES     F       2016-0… 2018-0… A      
#> 17 1639173065 SAKSHI     DUA     M.D.    YES     F       2005-0… 2019-0… A      
#> 18 1639173065 SAKSHI     DUA     M.D.    YES     F       2005-0… 2019-0… A      
#> 19 1790786416 NOAH       GOLDMAN M.D.    NO      M       2005-0… 2018-0… A      
#> 20 1962983775 <NA>       <NA>    <NA>    <NA>    <NA>    2018-0… 2018-0… A      
#> # … with 17 more variables: basic_name <chr>, basic_name_prefix <chr>,
#> #   basic_middle_name <chr>, basic_organization_name <chr>,
#> #   basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>,
#> #   basic_authorized_official_last_name <chr>,
#> #   basic_authorized_official_middle_name <chr>, …
```

### Validating NPIs

Just like credit card numbers, NPI numbers can be mistyped or corrupted
in transit. Likewise, officially-issued NPI numbers have a [check
digit](https://en.wikipedia.org/wiki/Check_digit) for error-checking
purposes. Use `npi_is_valid()` to check whether an NPI number you’ve
encountered is validly constructed:

``` r
# Validate NPIs
npi_is_valid(1234567893)
#> [1] TRUE
npi_is_valid(1234567898)
#> [1] FALSE
```

Note that this function doesn’t check whether the NPI numbers are
activated or deactivated (see
[\#22](https://github.com/ropensci/npi/issues/22#issuecomment-787642817)).
It merely checks for the number’s consistency with the NPI
specification. As such, it can help you detect and handle data quality
issues early.

## Set your own user agent

A [user agent](https://en.wikipedia.org/wiki/User_agent) is a way for
the software interacting with an API to tell it who or what is making
the request. This helps the API’s maintainers understand what systems
are using the API. By default, when `npi` makes a request to the NPPES
API, the request header references the name of the package and the URL
for the repository (e.g., ‘npi/0.2.0
(<https://github.com/ropensci/npi>)’). If you want to set a custom user
agent, update the value of the `npi_user_agent` option. For example, for
version 1.0.0 of an app called “my_app”, you could run the following
code:

``` r
options(npi_user_agent = "my_app/1.0.0")
```

## Package Website

`npi` has a [website](https://docs.ropensci.org/npi/) with release
notes, documentation on all user functions, and examples showing how the
package can be used.

## Reporting Bugs

Did you spot a bug? I’d love to hear about it at the [issues
page](https://github.com/ropensci/npi/issues).

## Code of Conduct

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.

## Contributing

Interested in learning how you can contribute to npi? Head over to the
[contributor guide](https://docs.ropensci.org/npi/CONTRIBUTING.html)—and
thanks for considering!

## How to cite this package

For the latest citation, see the [Authors and
Citation](https://docs.ropensci.org/npi/authors.html) page on the
package website.

## License

MIT (c) [Frank Farach](https://github.com/frankfarach)

This package’s logo is licensed under [CC BY-SA
4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.en) and
co-created by [Frank Farach](https://github.com/frankfarach) and [Sam
Parmar](https://github.com/parmsam). The logo uses a modified version of
an
[image](https://commons.wikimedia.org/wiki/File:Rod_of_Asclepius_(Search).svg)
of the [Rod of
Asclepius](https://en.wikipedia.org/wiki/Rod_of_Asclepius) and a
magnifying glass that is attributed to Evanherk, GFDL.
