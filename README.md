
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

`npi` exports four functions, all of which match the pattern "npi\_\*":

  - `npi_search()`: Search the NPI Registry and return the response as a
    [tibble](http://tibble.tidyverse.org/) with high-cardinality data
    organized into list columns.
  - `npi_summarize()`: A method for displaying a nice overview of
    results from `npi_search()`.
  - `npi_flatten()`: A method for flattening one or more list columns
    from a search result, joined by NPI number.
  - `npi_is_valid()`: Check the validity of one or more NPI numbers
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
#> # A tibble: 10 x 11
#>       npi enumeration_type basic other_names identifiers taxonomies
#>  *  <int> <chr>            <lis> <list>      <list>      <list>    
#>  1 1.19e9 Individual       <tib… <tibble [0… <tibble [0… <tibble […
#>  2 1.31e9 Individual       <tib… <tibble [0… <tibble [1… <tibble […
#>  3 1.64e9 Individual       <tib… <tibble [0… <tibble [3… <tibble […
#>  4 1.35e9 Individual       <tib… <tibble [0… <tibble [0… <tibble […
#>  5 1.56e9 Individual       <tib… <tibble [0… <tibble [1… <tibble […
#>  6 1.79e9 Individual       <tib… <tibble [0… <tibble [1… <tibble […
#>  7 1.56e9 Individual       <tib… <tibble [0… <tibble [0… <tibble […
#>  8 1.96e9 Organization     <tib… <tibble [0… <tibble [0… <tibble […
#>  9 1.43e9 Individual       <tib… <tibble [0… <tibble [0… <tibble […
#> 10 1.33e9 Individual       <tib… <tibble [0… <tibble [0… <tibble […
#> # … with 5 more variables: addresses <list>, practice_locations <list>,
#> #   endpoints <list>, created_date <dttm>, last_updated_date <dttm>
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
#> # A tibble: 10 x 6
#>        npi name   enumeration_type primary_practice… phone primary_taxonomy
#>      <int> <chr>  <chr>            <chr>             <chr> <chr>           
#>  1  1.19e9 ALYSS… Individual       5 E 98TH ST FL S… 212-… Physician Assis…
#>  2  1.31e9 MARK … Individual       16 PARK PL, NEW … 212-… Orthopaedic Sur…
#>  3  1.64e9 SAKSH… Individual       10 E 102ND ST, N… 212-… Internal Medici…
#>  4  1.35e9 SARAH… Individual       1335 DUBLIN RD S… 614-… Occupational Th…
#>  5  1.56e9 AMY T… Individual       1176 5TH AVE, NE… 212-… Internal Medici…
#>  6  1.79e9 NOAH … Individual       140 BERGEN STREE… 973-… Obstetrics & Gy…
#>  7  1.56e9 ROBYN… Individual       9 HOPE AVE STE 5… 781-… Nurse Practitio…
#>  8  1.96e9 LENOX… Organization     100 E 77TH ST, N… 212-… Nurse Anestheti…
#>  9  1.43e9 YONGH… Individual       34 MAPLE ST, NOR… 203-… Psychiatry & Ne…
#> 10  1.33e9 RAJEE… Individual       12401 E 17TH AVE… 347-… Nurse Practitio…
```

Suppose we just want the basic and taxonomy information for each NPI in
the result in a flattened data frame:

``` r
npi_flatten(nyc, c("basic", "taxonomies"))
#> # A tibble: 20 x 26
#>       npi basic_first_name basic_last_name basic_credential
#>     <int> <chr>            <chr>           <chr>           
#>  1 1.19e9 ALYSSA           COWNAN          PA              
#>  2 1.31e9 MARK             MOHRMANN        MD              
#>  3 1.31e9 MARK             MOHRMANN        MD              
#>  4 1.33e9 RAJEE            KRAUSE          AGPCNP-C        
#>  5 1.33e9 RAJEE            KRAUSE          AGPCNP-C        
#>  6 1.33e9 RAJEE            KRAUSE          AGPCNP-C        
#>  7 1.35e9 SARAH            LOWRY           OTR/L           
#>  8 1.35e9 SARAH            LOWRY           OTR/L           
#>  9 1.43e9 YONGHONG         TAN             <NA>            
#> 10 1.56e9 AMY              TIERSTEN        M.D.            
#> 11 1.56e9 ROBYN            NOHLING         FNP-BC, RD, LDN…
#> 12 1.56e9 ROBYN            NOHLING         FNP-BC, RD, LDN…
#> 13 1.56e9 ROBYN            NOHLING         FNP-BC, RD, LDN…
#> 14 1.56e9 ROBYN            NOHLING         FNP-BC, RD, LDN…
#> 15 1.56e9 ROBYN            NOHLING         FNP-BC, RD, LDN…
#> 16 1.56e9 ROBYN            NOHLING         FNP-BC, RD, LDN…
#> 17 1.64e9 SAKSHI           DUA             M.D.            
#> 18 1.64e9 SAKSHI           DUA             M.D.            
#> 19 1.79e9 NOAH             GOLDMAN         M.D.            
#> 20 1.96e9 <NA>             <NA>            <NA>            
#> # … with 22 more variables: basic_sole_proprietor <chr>,
#> #   basic_gender <chr>, basic_enumeration_date <chr>,
#> #   basic_last_updated <chr>, basic_status <chr>, basic_name <chr>,
#> #   basic_name_prefix <chr>, basic_middle_name <chr>,
#> #   basic_organization_name <chr>, basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>,
#> #   basic_authorized_official_last_name <chr>,
#> #   basic_authorized_official_middle_name <chr>,
#> #   basic_authorized_official_telephone_number <chr>,
#> #   basic_authorized_official_title_or_position <chr>,
#> #   taxonomies_code <chr>, taxonomies_desc <chr>,
#> #   taxonomies_primary <lgl>, taxonomies_state <chr>,
#> #   taxonomies_license <chr>, taxonomies_taxonomy_group <chr>
```

Or we can flatten the whole thing and prune back later:

``` r
npi_flatten(nyc)
#> # A tibble: 48 x 42
#>       npi basic_first_name basic_last_name basic_credential
#>     <int> <chr>            <chr>           <chr>           
#>  1 1.19e9 ALYSSA           COWNAN          PA              
#>  2 1.19e9 ALYSSA           COWNAN          PA              
#>  3 1.31e9 MARK             MOHRMANN        MD              
#>  4 1.31e9 MARK             MOHRMANN        MD              
#>  5 1.31e9 MARK             MOHRMANN        MD              
#>  6 1.31e9 MARK             MOHRMANN        MD              
#>  7 1.33e9 RAJEE            KRAUSE          AGPCNP-C        
#>  8 1.33e9 RAJEE            KRAUSE          AGPCNP-C        
#>  9 1.33e9 RAJEE            KRAUSE          AGPCNP-C        
#> 10 1.33e9 RAJEE            KRAUSE          AGPCNP-C        
#> # … with 38 more rows, and 38 more variables: basic_sole_proprietor <chr>,
#> #   basic_gender <chr>, basic_enumeration_date <chr>,
#> #   basic_last_updated <chr>, basic_status <chr>, basic_name <chr>,
#> #   basic_name_prefix <chr>, basic_middle_name <chr>,
#> #   basic_organization_name <chr>, basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>,
#> #   basic_authorized_official_last_name <chr>,
#> #   basic_authorized_official_middle_name <chr>,
#> #   basic_authorized_official_telephone_number <chr>,
#> #   basic_authorized_official_title_or_position <chr>,
#> #   identifiers_identifier <chr>, identifiers_code <chr>,
#> #   identifiers_desc <chr>, identifiers_state <chr>,
#> #   identifiers_issuer <chr>, taxonomies_code <chr>,
#> #   taxonomies_desc <chr>, taxonomies_primary <lgl>,
#> #   taxonomies_state <chr>, taxonomies_license <chr>,
#> #   taxonomies_taxonomy_group <chr>, addresses_country_code <chr>,
#> #   addresses_country_name <chr>, addresses_address_purpose <chr>,
#> #   addresses_address_type <chr>, addresses_address_1 <chr>,
#> #   addresses_address_2 <chr>, addresses_city <chr>,
#> #   addresses_state <chr>, addresses_postal_code <chr>,
#> #   addresses_telephone_number <chr>, addresses_fax_number <chr>
```

Now we’re ready to do whatever else we need to do with this data. Under
the hood, `npi_flatten()` has done a lot of data wrangling for us:

  - unnested the specified list columns
  - avoided potential naming collisions by prefixing the unnested names
    by their originating column name
  - joined the data together by NPI

### Validating NPIs

Use `npi_is_valid()` to check whether each element of a vector of
candidate numbers is a valid NPI number:

``` r
# Validate off NPIs
npi_is_valid(c(1234567893, 1234567898))
#> [1] TRUE
```

## Set your own user agent

By default, all request headers include a user agent that references
this repository. You can customize the user agent by setting the
`npi_user_agent` option:

``` r
options(npi_user_agent = "my_awesome_user_agent")
```

## Reporting Bugs

Did you spot a bug? I’d love to hear about it at the [issues
page](https://github.com/frankfarach/npi/issues).

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

## License

MIT (c) [Frank Farach](https://github.com/frankfarach)
