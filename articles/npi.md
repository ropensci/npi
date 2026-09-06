# Introduction to npi

``` r

library(npi)
```

This vignette provides a brief introduction to the npi package.

`npi` is an R package that allows R users to access the [U.S. National
Provider Identifier (NPI) Registry](https://npiregistry.cms.hhs.gov/)
API by the Center for Medicare and Medicaid Services (CMS).

The package makes it easy to obtain administrative data linked to a
specific individual or organizational healthcare provider. Additionally,
users can perform advanced searches based on provider name, location,
type of service, credentials, and many other attributes.

## Search registry

To search for providers in New York City, use the `city` argument in
[`npi_search()`](../reference/npi_search.md). By default, the search
returns up to 10 records as a tibble organized into list columns.

The live search examples below are shown without execution so this
vignette can be built without internet access. Run them in an
interactive session to retrieve current registry data.

``` r

nyc <- npi_search(city = "New York City")
nyc
```

Other search arguments for the function include `number`,
`enumeration_type`, `taxonomy_description`, `first_name`, `last_name`,
`use_first_name_alias`, `organization_name`, `address_purpose`, `state`,
`postal_code`, `country_code`, and `limit`.

Additionally, more than one search argument can be used at once.

``` r

nyc_multi <- npi_search(city = "New York City", state = "NY", enumeration_type = "org")
nyc_multi
```

Visit the function’s help page via
[`?npi_search`](../reference/npi_search.md) after installing and loading
the package for more details.

## Increasing number of records returned

The `limit` argument of [`npi_search()`](../reference/npi_search.md)
lets you set the maximum records to return from 1 to 1200 inclusive,
defaulting to 10 records if no value is specified.

``` r

nyc_25 <- npi_search(city = "New York City", limit = 25)
nyc_25
```

When using [`npi_search()`](../reference/npi_search.md), searches with
greater than 200 records (for example 300 records) may result in
multiple API calls. This is because the API itself returns up to 200
records per request, but allows previously requested records to be
skipped. [`npi_search()`](../reference/npi_search.md) will automatically
make additional API calls up to the API’s limit of 1200 records for a
unique set of query parameter values, and will still return a single
tibble. However, to save time, the function only makes additional
requests if needed. For example, if you request 1200 records, and 199
are returned in the first request, then the function does not need to
make a second request because there are no more records to return.

``` r

nyc_300 <- npi_search(city = "New York City", limit = 300)
nyc_300
```

The NPPES API documentation does not specify additional API rate
limitations. However, if you need more than 1200 NPI records for a set
of search terms, you will need to download the [NPPES Data Dissemination
File](https://download.cms.gov/nppes/NPI_Files.html).

## Obtaining more human-readable output

[`npi_summarize()`](../reference/npi_summarize.md) provides a more
human-readable overview of search results. For the executable examples
below, we use the bundled `npis` dataset: a saved sample of 10 provider
records, not the output of the live searches above.

``` r

nyc <- npi::npis
```

``` r

npi_summarize(nyc)
#> # A tibble: 10 × 6
#>         npi name  enumeration_type primary_practice_add…¹ phone primary_taxonomy
#>       <int> <chr> <chr>            <chr>                  <chr> <chr>           
#>  1   1.19e9 ALYS… Individual       5 E 98TH ST FL SREET4… 212-… Physician Assis…
#>  2   1.31e9 MARK… Individual       16 PARK PL, NEW YORK,… 212-… Orthopaedic Sur…
#>  3   1.64e9 SAKS… Individual       10 E 102ND ST, NEW YO… 212-… Internal Medici…
#>  4   1.35e9 SARA… Individual       1335 DUBLIN RD STE 20… 614-… Occupational Th…
#>  5   1.56e9 AMY … Individual       1176 5TH AVE, NEW YOR… 212-… Internal Medici…
#>  6   1.79e9 NOAH… Individual       140 BERGEN STREET LEV… 973-… Obstetrics & Gy…
#>  7   1.56e9 ROBY… Individual       9 HOPE AVE STE 500, W… 781-… Nurse Practitio…
#>  8   1.96e9 LENO… Organization     100 E 77TH ST, NEW YO… 212-… Nurse Anestheti…
#>  9   1.43e9 YONG… Individual       34 MAPLE ST, NORWALK,… 203-… Psychiatry & Ne…
#> 10   1.33e9 RAJE… Individual       12401 E 17TH AVE, AUR… 347-… Nurse Practitio…
#> # ℹ abbreviated name: ¹​primary_practice_address
```

Additionally, users can flatten all the list columns using
[`npi_flatten()`](../reference/npi_flatten.md).

``` r

npi_flatten(nyc)
#> # A tibble: 48 × 42
#>           npi basic_first_name basic_last_name basic_credential
#>         <int> <chr>            <chr>           <chr>           
#>  1 1194276360 ALYSSA           COWNAN          PA              
#>  2 1194276360 ALYSSA           COWNAN          PA              
#>  3 1306849641 MARK             MOHRMANN        MD              
#>  4 1306849641 MARK             MOHRMANN        MD              
#>  5 1306849641 MARK             MOHRMANN        MD              
#>  6 1306849641 MARK             MOHRMANN        MD              
#>  7 1326403213 RAJEE            KRAUSE          AGPCNP-C        
#>  8 1326403213 RAJEE            KRAUSE          AGPCNP-C        
#>  9 1326403213 RAJEE            KRAUSE          AGPCNP-C        
#> 10 1326403213 RAJEE            KRAUSE          AGPCNP-C        
#> # ℹ 38 more rows
#> # ℹ 38 more variables: basic_sole_proprietor <chr>, basic_gender <chr>,
#> #   basic_enumeration_date <chr>, basic_last_updated <chr>, basic_status <chr>,
#> #   basic_name <chr>, basic_name_prefix <chr>, basic_middle_name <chr>,
#> #   basic_organization_name <chr>, basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>, …
```

Alternatively, individual columns can be flattened for each npi by using
the `cols` argument. Only the columns specified will be flattened and
returned with the npi column by default.

``` r

npi_flatten(nyc, cols = c("basic", "taxonomies"))
#> # A tibble: 20 × 26
#>           npi basic_first_name basic_last_name basic_credential    
#>         <int> <chr>            <chr>           <chr>               
#>  1 1194276360 ALYSSA           COWNAN          PA                  
#>  2 1306849641 MARK             MOHRMANN        MD                  
#>  3 1306849641 MARK             MOHRMANN        MD                  
#>  4 1326403213 RAJEE            KRAUSE          AGPCNP-C            
#>  5 1326403213 RAJEE            KRAUSE          AGPCNP-C            
#>  6 1326403213 RAJEE            KRAUSE          AGPCNP-C            
#>  7 1346604592 SARAH            LOWRY           OTR/L               
#>  8 1346604592 SARAH            LOWRY           OTR/L               
#>  9 1427454529 YONGHONG         TAN             NA                  
#> 10 1558362566 AMY              TIERSTEN        M.D.                
#> 11 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN, MSN
#> 12 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN, MSN
#> 13 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN, MSN
#> 14 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN, MSN
#> 15 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN, MSN
#> 16 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN, MSN
#> 17 1639173065 SAKSHI           DUA             M.D.                
#> 18 1639173065 SAKSHI           DUA             M.D.                
#> 19 1790786416 NOAH             GOLDMAN         M.D.                
#> 20 1962983775 NA               NA              NA                  
#> # ℹ 22 more variables: basic_sole_proprietor <chr>, basic_gender <chr>,
#> #   basic_enumeration_date <chr>, basic_last_updated <chr>, basic_status <chr>,
#> #   basic_name <chr>, basic_name_prefix <chr>, basic_middle_name <chr>,
#> #   basic_organization_name <chr>, basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>,
#> #   basic_authorized_official_last_name <chr>, …
```
