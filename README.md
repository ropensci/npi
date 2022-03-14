
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
[![R-CMD-check](https://github.com/frankfarach/npi/workflows/R-CMD-check/badge.svg)](https://github.com/frankfarach/npi/actions)
[![Coverage
status](https://codecov.io/gh/frankfarach/npi/branch/master/graph/badge.svg)](https://codecov.io/github/frankfarach/npi?branch=master)
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

## Installation

Install `npi` directly from Github using the `devtools` package:

``` r
devtools::install_github("frankfarach/npi")
library(npi)
```

## Usage

`npi` exports four functions, all of which match the pattern “npi\_\*“:

-   `npi_search()`: Search the NPI Registry and return the response as a
    [tibble](https://tibble.tidyverse.org/) with high-cardinality data
    organized into list columns.
-   `npi_summarize()`: A method for displaying a nice overview of
    results from `npi_search()`.
-   `npi_flatten()`: A method for flattening one or more list columns
    from a search result, joined by NPI number.
-   `npi_is_valid()`: Check the validity of one or more NPI numbers
    using the official [NPI enumeration
    standard](https://www.cms.gov/Regulations-and-Guidance/Administrative-Simplification/NationalProvIdentStand/Downloads/NPIcheckdigit.pdf).

### Search the registry

`npi_search()` exposes nearly all of the NPPES API’s [search
parameters](https://npiregistry.cms.hhs.gov/registry/help-api). Let’s
say we wanted to find up to 10 organizational providers with primary
locations in New York City:

``` r
nyc <- npi_search(city = "New York City")
```

``` r
nyc
#> # A tibble: 10 × 11
#>       npi enumeration_type basic    other_names identifiers taxonomies addresses
#>  *  <int> <chr>            <list>   <list>      <list>      <list>     <list>   
#>  1 1.19e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  2 1.31e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  3 1.64e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  4 1.35e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  5 1.56e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  6 1.79e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  7 1.56e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  8 1.96e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  9 1.43e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> 10 1.33e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> # … with 4 more variables: practice_locations <list>, endpoints <list>,
#> #   created_date <dttm>, last_updated_date <dttm>
```

The full search results have four regular vector columns, `npi`,
`provider_type`, `created_date`, and `last_updated_date` and seven list
columns. Each list column is a collection of related data:

-   `basic`: Basic profile information about the provider
-   `other_names`: Other names used by the provider
-   `identifiers`: Other provider identifiers and credential information
-   `taxonomies`: Service classification and license information
-   `addresses`: Location and mailing address information
-   `practice_locations`: Provider’s practice locations
-   `endpoints`: Details about provider’s endpoints for health
    information exchange

If you’re comfortable [working with list
columns](https://r4ds.had.co.nz/many-models.html), this may be all you
need from the package. But let’s not stop just yet, because `npi`
provides convenience functions to summarize and extract the data you
need.

## Working with search results

Run `npi_summarize()` on your results to see a more human-readable
overview of what we’ve got:

``` r
npi_summarize(nyc)
#> # A tibble: 10 × 6
#>           npi name      enumeration_type primary_practic… phone primary_taxonomy
#>         <int> <chr>     <chr>            <chr>            <chr> <chr>           
#>  1 1194276360 ALYSSA C… Individual       5 E 98TH ST FL … 212-… Physician Assis…
#>  2 1306849641 MARK MOH… Individual       16 PARK PL, NEW… 212-… Orthopaedic Sur…
#>  3 1639173065 SAKSHI D… Individual       10 E 102ND ST, … 212-… Internal Medici…
#>  4 1346604592 SARAH LO… Individual       1335 DUBLIN RD … 614-… Occupational Th…
#>  5 1558362566 AMY TIER… Individual       1176 5TH AVE, N… 212-… Internal Medici…
#>  6 1790786416 NOAH GOL… Individual       140 BERGEN STRE… 973-… Obstetrics & Gy…
#>  7 1558713628 ROBYN NO… Individual       9 HOPE AVE STE … 781-… Nurse Practitio…
#>  8 1962983775 LENOX HI… Organization     100 E 77TH ST, … 212-… Nurse Anestheti…
#>  9 1427454529 YONGHONG… Individual       34 MAPLE ST, NO… 203-… Psychiatry & Ne…
#> 10 1326403213 RAJEE KR… Individual       12401 E 17TH AV… 347-… Nurse Practitio…
```

Suppose we just want the basic and taxonomy information for each NPI in
the result in a flattened data frame:

``` r
npi_flatten(nyc, c("basic", "taxonomies"))
#> # A tibble: 20 × 26
#>           npi basic_first_name basic_last_name basic_credential basic_sole_prop…
#>         <int> <chr>            <chr>           <chr>            <chr>           
#>  1 1194276360 ALYSSA           COWNAN          PA               NO              
#>  2 1306849641 MARK             MOHRMANN        MD               NO              
#>  3 1306849641 MARK             MOHRMANN        MD               NO              
#>  4 1326403213 RAJEE            KRAUSE          AGPCNP-C         NO              
#>  5 1326403213 RAJEE            KRAUSE          AGPCNP-C         NO              
#>  6 1326403213 RAJEE            KRAUSE          AGPCNP-C         NO              
#>  7 1346604592 SARAH            LOWRY           OTR/L            YES             
#>  8 1346604592 SARAH            LOWRY           OTR/L            YES             
#>  9 1427454529 YONGHONG         TAN             <NA>             NO              
#> 10 1558362566 AMY              TIERSTEN        M.D.             YES             
#> 11 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN… YES             
#> 12 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN… YES             
#> 13 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN… YES             
#> 14 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN… YES             
#> 15 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN… YES             
#> 16 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN… YES             
#> 17 1639173065 SAKSHI           DUA             M.D.             YES             
#> 18 1639173065 SAKSHI           DUA             M.D.             YES             
#> 19 1790786416 NOAH             GOLDMAN         M.D.             NO              
#> 20 1962983775 <NA>             <NA>            <NA>             <NA>            
#> # … with 21 more variables: basic_gender <chr>, basic_enumeration_date <chr>,
#> #   basic_last_updated <chr>, basic_status <chr>, basic_name <chr>,
#> #   basic_name_prefix <chr>, basic_middle_name <chr>,
#> #   basic_organization_name <chr>, basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>,
#> #   basic_authorized_official_last_name <chr>, …
```

Or we can flatten the whole thing and prune back later:

``` r
npi_flatten(nyc)
#> # A tibble: 48 × 42
#>           npi basic_first_name basic_last_name basic_credential basic_sole_prop…
#>         <int> <chr>            <chr>           <chr>            <chr>           
#>  1 1194276360 ALYSSA           COWNAN          PA               NO              
#>  2 1194276360 ALYSSA           COWNAN          PA               NO              
#>  3 1306849641 MARK             MOHRMANN        MD               NO              
#>  4 1306849641 MARK             MOHRMANN        MD               NO              
#>  5 1306849641 MARK             MOHRMANN        MD               NO              
#>  6 1306849641 MARK             MOHRMANN        MD               NO              
#>  7 1326403213 RAJEE            KRAUSE          AGPCNP-C         NO              
#>  8 1326403213 RAJEE            KRAUSE          AGPCNP-C         NO              
#>  9 1326403213 RAJEE            KRAUSE          AGPCNP-C         NO              
#> 10 1326403213 RAJEE            KRAUSE          AGPCNP-C         NO              
#> # … with 38 more rows, and 37 more variables: basic_gender <chr>,
#> #   basic_enumeration_date <chr>, basic_last_updated <chr>, basic_status <chr>,
#> #   basic_name <chr>, basic_name_prefix <chr>, basic_middle_name <chr>,
#> #   basic_organization_name <chr>, basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>,
#> #   basic_authorized_official_last_name <chr>, …
```

Now we’re ready to do whatever else we need to do with this data. Under
the hood, `npi_flatten()` has done a lot of data wrangling for us:

-   unnested the specified list columns
-   avoided potential naming collisions by prefixing the unnested names
    by their originating column name
-   joined the data together by NPI

### Validating NPIs

Use `npi_is_valid()` to check whether each element of a vector of
candidate numbers is a validly constructed NPI number:

``` r
# Validate off NPIs
npi_is_valid(1234567893)
#> [1] TRUE
npi_is_valid(1234567898)
#> [1] FALSE
```

Note that this function doesn’t check whether the NPI numbers are
activated or deactivated (see
[\#22](https://github.com/frankfarach/npi/issues/22#issuecomment-787642817)).

## Set your own user agent

By default, all request headers include a user agent that references
this repository. You can customize the user agent by setting the
`npi_user_agent` option:

``` r
options(npi_user_agent = "my_awesome_user_agent")
```

## Package Website

`npi` has a [website](https://frankfarach.github.io/npi/) with release
notes, documentation on all user functions, and examples showing how the
package can be used.

## Reporting Bugs

Did you spot a bug? I’d love to hear about it at the [issues
page](https://github.com/frankfarach/npi/issues).

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

## Contributing

Interested in learning how you can contribute to npi? Head over to the
[contributor guide](CONTRIBUTING.md)—and thanks for considering!

## How to cite this package

For the latest citation, see the [Authors and
Citation](https://frankfarach.github.io/npi/authors.html#citation) page
on the package website.

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
