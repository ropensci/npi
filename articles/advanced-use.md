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

These live search examples are shown without execution. They require
internet access when run interactively; registry results may change over
time.

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

npi_summarize(out)
```

Here we search for multiple zip codes in Los Angeles County.

``` r

codes <- c(90210, 90211, 90212)

zip_3 <- codes %>% 
  purrr::map(., ~ npi_search(postal_code  = .)) %>% 
  dplyr::bind_rows() 

npi_flatten(zip_3)
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

npi_summarize(combined_df)
```

## Combine and transform saved results

The following executable example uses the bundled
[`npi::npis`](../reference/npis.md) dataset, not the results of the live
searches above. It demonstrates combining two saved batches and then
summarizing and flattening the combined records without internet access.

``` r

saved_batches <- list(npi::npis[1:5, ], npi::npis[6:10, ])
combined <- dplyr::bind_rows(saved_batches)
npi_summarize(combined)
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
npi_flatten(combined, cols = c("basic", "taxonomies"))
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
