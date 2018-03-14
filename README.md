
<!-- README.md is generated from README.Rmd. Please edit that file -->
npi
===

> Access the U.S. National Provider Identifier Registry API

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![Travis build status](https://travis-ci.org/frankfarach/npi.svg?branch=master)](https://travis-ci.org/frankfarach/npi) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/frankfarach/npi?branch=master&svg=true)](https://ci.appveyor.com/project/frankfarach/npi) [![Coverage status](https://codecov.io/gh/frankfarach/npi/branch/master/graph/badge.svg)](https://codecov.io/github/frankfarach/npi?branch=master)

Provide access to the API for the U.S. National Provider Identifier (NPI) Registry Public Search provided by the Center for Medicare and Medicaid Services (CMS): <https://npiregistry.cms.hhs.gov/>.

Installation
------------

This package can be installed directly from this Github repo:

``` r
devtools::install_github("frankfarach/npi")
library(npi)
```

Usage
-----

### Searching

`search_npi()` searches the public NPI Registry using the [parameters](https://npiregistry.cms.hhs.gov/registry/help-api) made available by the API and returns the results as a [tidy data frame](http://tibble.tidyverse.org/), or tibble.

``` r
# Search for orthopedic individual providers in Atlanta, Georgia
res <- search_npi(provider_type = 1,
                  taxonomy = "Orthoped*",
                  city = "Atlanta",
                  state = "GA")
```

### Working with Search Results

If you just want the NPIs from the search results, use `get_npi()`: It accepts an `npi_api` S3 object, extracts the NPIs from it, and returns them as an integer vector.

``` r
get_npi(res)
#>  [1] 1801876693 1265409692 1124088042 1558321471 1174583082 1205896693
#>  [7] 1255392668 1215998638 1689637746 1730144775 1447216759 1124084108
#> [13] 1083666739 1790714434 1477577484 1720167083 1740359918 1699805358
#> [19] 1538299474 1619175395 1346439437 1720267610 1376723239 1073767216
#> [25] 1326372293 1417283391 1588995054 1750601464 1649591173 1235450800
#> [31] 1689985061 1982911590 1902116809 1477863157 1861910770 1710248901
#> [37] 1992066013 1831442821 1407289622 1023449048 1619398534 1669897518
#> [43] 1861800757 1366851107 1689073553 1952707457 1013394915 1033265319
#> [49] 1174969398 1114329455 1417323627 1235596156 1205380342 1083168975
#> [55] 1528515111 1538616305 1033656806 1093242620 1649791005 1881118016
#> [61] 1508384074
```

`get_results()` accepts a `npi_api` S3 object, organizes and cleans the data, and returns it as a tibble:

``` r
df <- get_results(res)
glimpse(df)
#> Observations: 61
#> Variables: 18
#> $ number             <int> 1801876693, 1265409692, 1124088042, 1558321...
#> $ enumeration_type   <chr> "NPI-1", "NPI-1", "NPI-1", "NPI-1", "NPI-1"...
#> $ created_epoch      <dttm> 2006-01-17 16:00:00, 2006-03-02 16:00:00, ...
#> $ last_updated_epoch <dttm> 2015-05-12 15:44:26, 2014-06-02 17:00:00, ...
#> $ taxonomies         <list> [<# A tibble: 2 x 5,   state code       pr...
#> $ addresses          <list> [<# A tibble: 2 x 11,   city   address_2 t...
#> $ identifiers        <list> [# A tibble: 0 x 0, <# A tibble: 1 x 5,   ...
#> $ status             <chr> "A", "A", "A", "A", "A", "A", "A", "A", "A"...
#> $ credential         <chr> "OPA-C", "PT", "PT, CHT", "PT", "PT", "PT",...
#> $ first_name         <chr> "TONY", "AUGUSTUS", "HEATHER", "DOUGLAS", "...
#> $ last_name          <chr> "GRIGGS", "WOLFF", "HOWROYD", "STURGESS", "...
#> $ middle_name        <chr> "M", "G.", "A.", "M.", NA, "L.", "L.", "K."...
#> $ name               <chr> "GRIGGS TONY", "WOLFF AUGUSTUS", "HOWROYD H...
#> $ gender             <chr> "M", "M", "F", "M", "M", "M", "F", "F", "M"...
#> $ sole_proprietor    <chr> "NO", "NO", "NO", "NO", "NO", "NO", "NO", "...
#> $ last_updated       <chr> "2015-05-12", "2014-06-03", "2008-04-08", "...
#> $ enumeration_date   <chr> "2006-01-18", "2006-03-03", "2006-03-24", "...
#> $ name_prefix        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
```

The data is organized according to its relationship to the NPI (`number` column). Data elements with a 1-to-1 relationship with NPI appear in vector columns, whereas elements with a many-to-1 relationship with NPI exist within [list columns](http://r4ds.had.co.nz/many-models.html#list-columns-1). Each element of a list column is a list of tibbles.

``` r
df %>% 
  select(number, taxonomies, addresses, identifiers)
#> # A tibble: 61 x 4
#>        number taxonomies       addresses         identifiers     
#>         <int> <list>           <list>            <list>          
#>  1 1801876693 <tibble [2 × 5]> <tibble [2 × 11]> <tibble [0 × 0]>
#>  2 1265409692 <tibble [1 × 5]> <tibble [2 × 11]> <tibble [1 × 5]>
#>  3 1124088042 <tibble [2 × 5]> <tibble [2 × 11]> <tibble [0 × 0]>
#>  4 1558321471 <tibble [1 × 5]> <tibble [2 × 11]> <tibble [0 × 0]>
#>  5 1174583082 <tibble [1 × 5]> <tibble [2 × 11]> <tibble [0 × 0]>
#>  6 1205896693 <tibble [1 × 5]> <tibble [2 × 11]> <tibble [0 × 0]>
#>  7 1255392668 <tibble [1 × 5]> <tibble [2 × 11]> <tibble [0 × 0]>
#>  8 1215998638 <tibble [1 × 5]> <tibble [2 × 11]> <tibble [0 × 0]>
#>  9 1689637746 <tibble [2 × 5]> <tibble [2 × 11]> <tibble [3 × 5]>
#> 10 1730144775 <tibble [1 × 5]> <tibble [2 × 11]> <tibble [0 × 0]>
#> # ... with 51 more rows
```

There are three such columns:

-   `taxonomies`: Service classification and licnese information
-   `addresses`: Location and mailing address information
-   `identifiers`: Miscellaneous provider identifiers and credential information

Any of these columns can be extracted as a tidy data frame using `dplyr::unnest()`:

``` r
tax <- df %>%
  select(number, taxonomies) %>% 
  unnest()
tax
#> # A tibble: 106 x 7
#>        number state code       primary license  desc        taxonomy_group
#>         <int> <chr> <chr>      <lgl>   <chr>    <chr>       <chr>         
#>  1 1801876693 ""    363A00000X F       ""       Physician … <NA>          
#>  2 1801876693 ""    246ZX2200X T       ""       Specialist… <NA>          
#>  3 1265409692 GA    2251X0800X T       PT007710 Physical T… <NA>          
#>  4 1124088042 GA    2251X0800X F       PT001113 Physical T… <NA>          
#>  5 1124088042 GA    2251H1200X T       PT001113 Physical T… <NA>          
#>  6 1558321471 GA    2251X0800X T       PT008033 Physical T… <NA>          
#>  7 1174583082 GA    2251X0800X T       PT002690 Physical T… <NA>          
#>  8 1205896693 GA    2251X0800X T       PT002287 Physical T… <NA>          
#>  9 1255392668 GA    2251X0800X T       PT004041 Physical T… <NA>          
#> 10 1215998638 GA    2251X0800X T       PT007851 Physical T… <NA>          
#> # ... with 96 more rows
```

By repeating this process with other list columns, you can create multiple tidy data frames and join them to make your own master tidy data frame.

``` r
# Create tidy data frame of identifiers
ids <- df %>%
  select(number, identifiers) %>% 
  unnest()
ids
#> # A tibble: 9 x 6
#>       number code  issuer                    state identifier  desc    
#>        <int> <chr> <chr>                     <chr> <chr>       <chr>   
#> 1 1265409692 01    RR MEDICARE               GA    P00785970   Other   
#> 2 1689637746 05    ""                        GA    591304637A  MEDICAID
#> 3 1689637746 05    ""                        GA    591304637C  MEDICAID
#> 4 1689637746 05    ""                        GA    591304637B  MEDICAID
#> 5 1790714434 01    BCBS AUSTELL LOCATION     GA    52198163006 Other   
#> 6 1790714434 01    BCBS WOODSTOCK LOCATION   GA    52198163004 Other   
#> 7 1790714434 01    BCBS MARIETTA LOCATION    GA    52198163002 Other   
#> 8 1790714434 01    BCBS DOUGLASVILLE LOCATIO GA    52198163008 Other   
#> 9 1720167083 01    STATE BOARD OF P.T.       GA    PT007055    Other

# Join taxonomies and identifiers by `number`
left_join(tax, ids, by = "number")
#> # A tibble: 113 x 12
#>     number state.x code.x primary license desc.x     taxonomy_group code.y
#>      <int> <chr>   <chr>  <lgl>   <chr>   <chr>      <chr>          <chr> 
#>  1  1.80e⁹ ""      363A0… F       ""      Physician… <NA>           <NA>  
#>  2  1.80e⁹ ""      246ZX… T       ""      Specialis… <NA>           <NA>  
#>  3  1.27e⁹ GA      2251X… T       PT0077… Physical … <NA>           01    
#>  4  1.12e⁹ GA      2251X… F       PT0011… Physical … <NA>           <NA>  
#>  5  1.12e⁹ GA      2251H… T       PT0011… Physical … <NA>           <NA>  
#>  6  1.56e⁹ GA      2251X… T       PT0080… Physical … <NA>           <NA>  
#>  7  1.17e⁹ GA      2251X… T       PT0026… Physical … <NA>           <NA>  
#>  8  1.21e⁹ GA      2251X… T       PT0022… Physical … <NA>           <NA>  
#>  9  1.26e⁹ GA      2251X… T       PT0040… Physical … <NA>           <NA>  
#> 10  1.22e⁹ GA      2251X… T       PT0078… Physical … <NA>           <NA>  
#> # ... with 103 more rows, and 4 more variables: issuer <chr>,
#> #   state.y <chr>, identifier <chr>, desc.y <chr>
```

### Paging

By default, `search_npi()` will return at most 200 records per request, which is the maximum set by the API. To return additional records, specify the number of records to skip using the skip argument. The API limits the total number of returned records across requests to 1,200 for a set a query parameters:

``` r
# Return records 200-400
search_npi(
  city = "San Francisco",
  state = "CA",
  skip = 200
  ) %>%
  get_results()
#> # A tibble: 200 x 33
#>        number enumeration_type created_epoch       last_updated_epoch 
#>         <int> <chr>            <dttm>              <dttm>             
#>  1 1003808338 NPI-1            2005-08-22 17:00:00 2008-12-10 16:00:00
#>  2 1609868934 NPI-1            2005-08-22 17:00:00 2007-07-07 17:00:00
#>  3 1942293071 NPI-2            2005-08-23 17:00:00 2007-07-07 17:00:00
#>  4 1891172219 NPI-1            2015-05-04 17:00:00 2015-05-05 15:07:36
#>  5 1639162514 NPI-1            2005-08-24 17:00:00 2012-09-17 17:00:00
#>  6 1245223031 NPI-1            2005-08-25 17:00:00 2007-07-07 17:00:00
#>  7 1689667495 NPI-1            2005-08-25 17:00:00 2014-03-18 17:00:00
#>  8 1518950351 NPI-1            2005-08-25 17:00:00 2008-10-02 17:00:00
#>  9 1780677526 NPI-1            2005-08-25 17:00:00 2007-09-04 17:00:00
#> 10 1639162480 NPI-2            2005-08-25 17:00:00 2013-07-25 17:00:00
#> # ... with 190 more rows, and 29 more variables: taxonomies <list>,
#> #   addresses <list>, identifiers <list>, status <chr>, credential <chr>,
#> #   first_name <chr>, last_name <chr>, last_updated <chr>, name <chr>,
#> #   gender <chr>, sole_proprietor <chr>, enumeration_date <chr>,
#> #   middle_name <chr>, name_suffix <chr>, name_prefix <chr>,
#> #   authorized_official_telephone_number <chr>,
#> #   authorized_official_middle_name <chr>,
#> #   authorized_official_last_name <chr>, organization_name <chr>,
#> #   organizational_subpart <chr>, authorized_official_name_prefix <chr>,
#> #   authorized_official_title_or_position <chr>,
#> #   authorized_official_first_name <chr>, deactivation_date <chr>,
#> #   reactivation_date <chr>, authorized_official_credential <chr>,
#> #   parent_organization_legal_business_name <chr>,
#> #   parent_organization_ein <chr>, authorized_official_name_suffix <chr>
```

### Validating NPIs

Use `is_valid_npi()` to check whether a candidate number is a valid NPI number:

``` r
# Validate one-off NPIs
is_valid_npi(1234567893)
#> [1] TRUE
is_valid_npi(1234567898)
#> [1] FALSE
```

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

License
-------

MIT (c) [Frank Farach](https://github.com/frankfarach)
