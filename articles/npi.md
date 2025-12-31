# Introduction to npi

``` r
library(npi)
```

This vignette provides an brief introduction to the npi package.

`npi` is an R package that allows R users to access the [U.S. National
Provider Identifier (NPI) Registry](https://npiregistry.cms.hhs.gov/)
API by the Center for Medicare and Medicaid Services (CMS).

The package makes it easy to obtain administrative data linked to a
specific individual or organizational healthcare provider. Additionally,
users can perform advanced searches based on provider name, location,
type of service, credentials, and many other attributes.

## Search registry

To explore organizational providers with primary locations in New York
City, we could use the `city` argument in the
[`npi_search()`](../reference/npi_search.md). The nyc dataset here finds
10 organizational providers with primary locations in New York City,
since 10 is the default number of records that are returned in
[`npi_search()`](../reference/npi_search.md). The response is a tibble
that has high-cardinality data organized into list columns.

``` r
nyc <- npi_search(city = "New York City")
#> 10 records requested
#> Requesting records 0-10...
nyc
#> # A tibble: 10 × 11
#>       npi enumeration_type basic    other_names identifiers taxonomies addresses
#>  *  <int> <chr>            <list>   <list>      <list>      <list>     <list>   
#>  1 1.21e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  2 1.27e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  3 1.68e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  4 1.98e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  5 1.49e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  6 1.59e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  7 1.94e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  8 1.73e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  9 1.63e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> 10 1.64e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> # ℹ 4 more variables: practice_locations <list>, endpoints <list>,
#> #   created_date <dttm>, last_updated_date <dttm>
```

Other search arguments for the function include `number`,
`enumeration_type`, `taxonomy_description`, `first_name`, `last_name`,
`use_first_name_alias`, `organization_name`, `address_purpose`, `state`,
`postal_code`, `country_code`, and `limit`.

Additionally, more than one search argument can be used at once.

``` r
nyc_multi <- npi_search(city = "New York City", state = "NY", enumeration_type = "org")
#> 10 records requested
#> Requesting records 0-10...
nyc_multi
#> # A tibble: 10 × 11
#>       npi enumeration_type basic    other_names identifiers taxonomies addresses
#>  *  <int> <chr>            <list>   <list>      <list>      <list>     <list>   
#>  1 1.77e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  2 1.64e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  3 1.95e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  4 1.00e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  5 1.35e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  6 1.97e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  7 1.23e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  8 1.34e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  9 1.63e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> 10 1.73e9 Organization     <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> # ℹ 4 more variables: practice_locations <list>, endpoints <list>,
#> #   created_date <dttm>, last_updated_date <dttm>
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
#> 25 records requested
#> Requesting records 0-25...
nyc_25
#> # A tibble: 25 × 11
#>       npi enumeration_type basic    other_names identifiers taxonomies addresses
#>  *  <int> <chr>            <list>   <list>      <list>      <list>     <list>   
#>  1 1.21e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  2 1.27e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  3 1.68e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  4 1.98e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  5 1.49e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  6 1.59e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  7 1.94e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  8 1.73e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  9 1.63e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> 10 1.64e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> # ℹ 15 more rows
#> # ℹ 4 more variables: practice_locations <list>, endpoints <list>,
#> #   created_date <dttm>, last_updated_date <dttm>
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
#> 300 records requested
#> Requesting records 0-200...
#> Requesting records 200-300...
nyc_300
#> # A tibble: 300 × 11
#>       npi enumeration_type basic    other_names identifiers taxonomies addresses
#>  *  <int> <chr>            <list>   <list>      <list>      <list>     <list>   
#>  1 1.21e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  2 1.27e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  3 1.68e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  4 1.98e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  5 1.49e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  6 1.59e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  7 1.94e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  8 1.73e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#>  9 1.63e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> 10 1.64e9 Individual       <tibble> <tibble>    <tibble>    <tibble>   <tibble> 
#> # ℹ 290 more rows
#> # ℹ 4 more variables: practice_locations <list>, endpoints <list>,
#> #   created_date <dttm>, last_updated_date <dttm>
```

The NPPES API documentation does not specify additional API rate
limitations. However, if you need more than 1200 NPI records for a set
of search terms, you will need to download the [NPPES Data Dissemination
File](https://download.cms.gov/nppes/NPI_Files.html).

## Obtaining more human-readable output

[`npi_summarize()`](../reference/npi_summarize.md) provides a more
human-readable overview of output already obtained through
[`npi_search()`](../reference/npi_search.md).

``` r
npi_summarize(nyc)
#> # A tibble: 10 × 6
#>         npi name  enumeration_type primary_practice_add…¹ phone primary_taxonomy
#>       <int> <chr> <chr>            <chr>                  <chr> <chr>           
#>  1   1.21e9 MOHA… Individual       506 LENOX AVENUE, HAR… 212-… Student in an O…
#>  2   1.27e9 MARK… Individual       1090 AMSTERDAM AVENUE… 212-… Psychiatry & Ne…
#>  3   1.68e9 JUDI… Individual       425 RIVERSIDE DR #8C,… 212-… Student in an O…
#>  4   1.98e9 UNKN… Individual       WESTCHESTER MEDICAL C… 914-… Internal Medici…
#>  5   1.49e9 RAKS… Individual       JACOBI MEDICAL CENTER… 718-… Student in an O…
#>  6   1.59e9 DANI… Individual       NA                     212-… Social Worker   
#>  7   1.94e9 AJAN… Individual       NA                     718-… Social Worker, …
#>  8   1.73e9 SAI … Individual       1545 ATLANTIC AVENUE,… 718-… Student in an O…
#>  9   1.63e9 MOHA… Individual       NA                     212-… Student in an O…
#> 10   1.64e9 MIRI… Individual       325 EAST 80TH ST #1C,… 212-… Student in an O…
#> # ℹ abbreviated name: ¹​primary_practice_address
```

Additionally, users can flatten all the list columns using
[`npi_flatten()`](../reference/npi_flatten.md).

``` r
npi_flatten(nyc)
#> # A tibble: 28 × 56
#>          npi basic_first_name basic_last_name basic_middle_name basic_credential
#>        <int> <chr>            <chr>           <chr>             <chr>           
#>  1    1.21e9 MOHAMED          ABDELGADER      SATI SHAMPOOL     M.B.B.S         
#>  2    1.21e9 MOHAMED          ABDELGADER      SATI SHAMPOOL     M.B.B.S         
#>  3    1.27e9 MARK             ABROMS          NA                NA              
#>  4    1.27e9 MARK             ABROMS          NA                NA              
#>  5    1.49e9 RAKSHEETH        AGARWAL         NA                M.D.            
#>  6    1.49e9 RAKSHEETH        AGARWAL         NA                M.D.            
#>  7    1.59e9 DANISH           AHMAD           A                 M.D.            
#>  8    1.59e9 DANISH           AHMAD           A                 M.D.            
#>  9    1.59e9 DANISH           AHMAD           A                 M.D.            
#> 10    1.59e9 DANISH           AHMAD           A                 M.D.            
#> # ℹ 18 more rows
#> # ℹ 51 more variables: basic_sole_proprietor <chr>, basic_sex <chr>,
#> #   basic_enumeration_date <chr>, basic_last_updated <chr>, basic_status <chr>,
#> #   basic_certification_date <chr>, basic_name_prefix <chr>,
#> #   basic_name_suffix <chr>, other_names_type <chr>, other_names_code <chr>,
#> #   other_names_first_name <chr>, other_names_last_name <chr>,
#> #   other_names_middle_name <chr>, other_names_prefix <chr>, …
```

Alternatively, individual columns can be flattened for each npi by using
the `cols` argument. Only the columns specified will be flattened and
returned with the npi column by default.

``` r
npi_flatten(nyc, cols = c("basic", "taxonomies"))
#> # A tibble: 12 × 19
#>          npi basic_first_name basic_last_name basic_middle_name basic_credential
#>        <int> <chr>            <chr>           <chr>             <chr>           
#>  1    1.21e9 MOHAMED          ABDELGADER      SATI SHAMPOOL     M.B.B.S         
#>  2    1.27e9 MARK             ABROMS          NA                NA              
#>  3    1.49e9 RAKSHEETH        AGARWAL         NA                M.D.            
#>  4    1.59e9 DANISH           AHMAD           A                 M.D.            
#>  5    1.59e9 DANISH           AHMAD           A                 M.D.            
#>  6    1.63e9 MOHAMMED         AKHTAR          ZEESHAN           MD PhD          
#>  7    1.64e9 MIRIAM           AKINS           F                 LCSW            
#>  8    1.64e9 MIRIAM           AKINS           F                 LCSW            
#>  9    1.68e9 JUDITH           ADELSON         D                 LCSW            
#> 10    1.73e9 SAI ANUSHA       AKELLA          NA                M.D             
#> 11    1.94e9 AJANG            AJZACHI         NA                DMD             
#> 12    1.98e9 UNKNOWN          ADILA           NA                NA              
#> # ℹ 14 more variables: basic_sole_proprietor <chr>, basic_sex <chr>,
#> #   basic_enumeration_date <chr>, basic_last_updated <chr>, basic_status <chr>,
#> #   basic_certification_date <chr>, basic_name_prefix <chr>,
#> #   basic_name_suffix <chr>, taxonomies_code <chr>,
#> #   taxonomies_taxonomy_group <chr>, taxonomies_desc <chr>,
#> #   taxonomies_primary <lgl>, taxonomies_state <chr>, taxonomies_license <chr>
```
