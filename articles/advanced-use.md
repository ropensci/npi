# Advanced Uses

``` r

library(npi)
library(purrr)
```

This vignette explores advanced uses of the npi package.

`npi` is an R package that allows R users to access the [U.S. National
Provider Identifier (NPI) Registry](https://npiregistry.cms.hhs.gov/)
API by the Center for Medicare and Medicaid Services (CMS). The package
makes it easy to obtain administrative data linked to a specific
individual or organizational healthcare provider. Additionally, users
can perform advanced searches based on provider name, location, type of
service, credentials, and many other attributes.

See the npi::npi vignette for an introduction to the package.

## Note on NPI Downloadable Files

CMS regularly releases full NPI data files
[here](https://download.cms.gov/nppes/NPI_Files.html). We recommend that
users download the data file if they need to work with the entire
dataset. The API and [`npi_search()`](../reference/npi_search.md)
returns a maximum of 1,200 records. Also consider downloading the entire
data if you need to work with more than the maximum. Data dissemination
files are zipped and will exceed 4GB upon decompression.

## Run `npi_search()` on multiple search terms

[`npi_search()`](../reference/npi_search.md) enables search for a
defined set query parameters. The function is not designed for search on
multiple values of the same argument at once, as for example in the case
of multiple NPI numbers in a single function call. However, users can
still serially execute searches for multiple values of a single query
parameter by using `npi` in combination with the
[`purrr`](https://purrr.tidyverse.org/) package. In the example below,
we search multiple NPI numbers. A single tibble is returned with record
information corresponding to matching records. The
[purrr:map()](https://purrr.tidyverse.org/reference/map.html) function
is used to apply the [`npi_search()`](../reference/npi_search.md)
function on each element of the vector. Thereafter, the
[dplyr::bind_rows()](https://dplyr.tidyverse.org/reference/bind.html)
function is used to combine the list of dataframes together into a
single dataframe.

``` r

npis <- c(1992708929, 1831192848, 1699778688, 1111111111)  # Last element doesn't exist

out <- npis %>% 
  purrr::map(., ~ npi_search(number = .)) %>% 
  dplyr::bind_rows()
#> 10 records requested
#> Requesting records 0-10...
#> 10 records requested
#> Requesting records 0-10...
#> 10 records requested
#> Requesting records 0-10...
#> 10 records requested
#> Requesting records 0-10...

npi_summarize(out)
#> # A tibble: 2 × 6
#>         npi name  enumeration_type primary_practice_add…¹ phone primary_taxonomy
#>       <int> <chr> <chr>            <chr>                  <chr> <chr>           
#> 1    1.99e9 NOVA… Organization     NA                     404-… Clinic/Center, …
#> 2    1.83e9 MATT… Individual       NA                     770-… Orthopaedic Sur…
#> # ℹ abbreviated name: ¹​primary_practice_address
```

Here we search for multiple zip codes in Los Angeles County.

``` r

codes <- c(90210, 90211, 90212)

zip_3 <- codes %>% 
  purrr::map(., ~ npi_search(postal_code  = .)) %>% 
  dplyr::bind_rows() 
#> 10 records requested
#> Requesting records 0-10...
#> 10 records requested
#> Requesting records 0-10...
#> 10 records requested
#> Requesting records 0-10...

npi_flatten(zip_3)
#> # A tibble: 104 × 47
#>         npi basic_authorized_off…¹ basic_authorized_off…² basic_authorized_off…³
#>       <int> <chr>                  <chr>                  <chr>                 
#>  1   1.15e9 AARON                  PERLMUTTER             NA                    
#>  2   1.15e9 AARON                  PERLMUTTER             NA                    
#>  3   1.15e9 AARON                  PERLMUTTER             NA                    
#>  4   1.15e9 AARON                  PERLMUTTER             NA                    
#>  5   1.15e9 AARON                  PERLMUTTER             NA                    
#>  6   1.15e9 AARON                  PERLMUTTER             NA                    
#>  7   1.15e9 AARON                  PERLMUTTER             NA                    
#>  8   1.15e9 AARON                  PERLMUTTER             NA                    
#>  9   1.15e9 AARON                  PERLMUTTER             NA                    
#> 10   1.15e9 AARON                  PERLMUTTER             NA                    
#> # ℹ 94 more rows
#> # ℹ abbreviated names: ¹​basic_authorized_official_first_name,
#> #   ²​basic_authorized_official_last_name,
#> #   ³​basic_authorized_official_middle_name
#> # ℹ 43 more variables: basic_authorized_official_name_prefix <chr>,
#> #   basic_authorized_official_name_suffix <chr>,
#> #   basic_authorized_official_telephone_number <chr>, …
```

Consult the R for Data Science [chapter on
iteration](https://r4ds.had.co.nz/iteration.html) to learn more about
using the `purrr` package.

Alternatively, you can use a simple for loop instead if you are
unfamiliar with the tidyverse approach.

``` r

npis <- c(1992708929, 1831192848, 1699778688, 1111111111)  # Last element doesn't exist
combined_df  <- data.frame()
for (i in npis) {
  combined_df <- rbind(combined_df, npi_search(number = i))
}
#> 10 records requested
#> Requesting records 0-10...
#> 10 records requested
#> Requesting records 0-10...
#> 10 records requested
#> Requesting records 0-10...
#> 10 records requested
#> Requesting records 0-10...

npi_summarize(combined_df)
#> # A tibble: 2 × 6
#>         npi name  enumeration_type primary_practice_add…¹ phone primary_taxonomy
#>       <int> <chr> <chr>            <chr>                  <chr> <chr>           
#> 1    1.99e9 NOVA… Organization     NA                     404-… Clinic/Center, …
#> 2    1.83e9 MATT… Individual       NA                     770-… Orthopaedic Sur…
#> # ℹ abbreviated name: ¹​primary_practice_address
```
