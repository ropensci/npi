# Flatten NPI search results

This function takes an `npi_results` S3 object returned by
[`npi_search`](npi_search.md) and flattens its list columns. It unnests
the lists columns and left joins them by `npi`. You can optionally
specify which columns from `df` to include.

## Usage

``` r
# S3 method for class 'npi_results'
npi_flatten(df, cols = NULL, key = "npi")
```

## Arguments

- df:

  A data frame containing the results of a call to
  [`npi_search`](npi_search.md).

- cols:

  If non-NULL, only the named columns specified here will be be
  flattened and returned along with `npi`.

- key:

  A quoted column name from `df` to use as a matching key. The default
  value is `"npi"`.

## Value

A data frame (tibble) with flattened list columns.

## Details

The names of unnested columns are prefixed by the name of their
originating list column to avoid name clashes and show their lineage.
List columns containing all NULL data will be absent from the result
because there are no columns to unnest.

## Examples

``` r
# Flatten all list columns
data(npis)
npi_flatten(npis)
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

# Only flatten specified columns
npi_flatten(npis, cols = c("basic", "identifiers"))
#> # A tibble: 12 × 25
#>           npi basic_first_name basic_last_name basic_credential    
#>         <int> <chr>            <chr>           <chr>               
#>  1 1194276360 ALYSSA           COWNAN          PA                  
#>  2 1306849641 MARK             MOHRMANN        MD                  
#>  3 1326403213 RAJEE            KRAUSE          AGPCNP-C            
#>  4 1346604592 SARAH            LOWRY           OTR/L               
#>  5 1427454529 YONGHONG         TAN             NA                  
#>  6 1558362566 AMY              TIERSTEN        M.D.                
#>  7 1558713628 ROBYN            NOHLING         FNP-BC, RD, LDN, MSN
#>  8 1639173065 SAKSHI           DUA             M.D.                
#>  9 1639173065 SAKSHI           DUA             M.D.                
#> 10 1639173065 SAKSHI           DUA             M.D.                
#> 11 1790786416 NOAH             GOLDMAN         M.D.                
#> 12 1962983775 NA               NA              NA                  
#> # ℹ 21 more variables: basic_sole_proprietor <chr>, basic_gender <chr>,
#> #   basic_enumeration_date <chr>, basic_last_updated <chr>, basic_status <chr>,
#> #   basic_name <chr>, basic_name_prefix <chr>, basic_middle_name <chr>,
#> #   basic_organization_name <chr>, basic_organizational_subpart <chr>,
#> #   basic_authorized_official_credential <chr>,
#> #   basic_authorized_official_first_name <chr>,
#> #   basic_authorized_official_last_name <chr>, …
```
