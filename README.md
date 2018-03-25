
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
res
#> # A tibble: 61 x 18
#>        number enumeration_type created_epoch       last_updated_epoch 
#>         <int> <chr>            <dttm>              <dttm>             
#>  1 1801876693 NPI-1            2006-01-17 16:00:00 2015-05-12 15:44:26
#>  2 1265409692 NPI-1            2006-03-02 16:00:00 2014-06-02 17:00:00
#>  3 1124088042 NPI-1            2006-03-23 16:00:00 2008-04-07 17:00:00
#>  4 1558321471 NPI-1            2006-03-23 16:00:00 2008-04-07 17:00:00
#>  5 1174583082 NPI-1            2006-03-23 16:00:00 2010-03-17 17:00:00
#>  6 1205896693 NPI-1            2006-03-27 16:00:00 2008-04-07 17:00:00
#>  7 1255392668 NPI-1            2006-03-27 16:00:00 2008-04-07 17:00:00
#>  8 1215998638 NPI-1            2006-03-27 16:00:00 2008-04-07 17:00:00
#>  9 1689637746 NPI-1            2006-04-09 17:00:00 2011-06-01 17:00:00
#> 10 1730144775 NPI-1            2006-04-19 17:00:00 2008-04-07 17:00:00
#> # ... with 51 more rows, and 14 more variables: taxonomies <list>,
#> #   addresses <list>, identifiers <list>, status <chr>, credential <list>,
#> #   first_name <chr>, last_name <chr>, middle_name <chr>, name <chr>,
#> #   gender <chr>, sole_proprietor <chr>, last_updated <chr>,
#> #   enumeration_date <chr>, name_prefix <chr>
```

### Working with Search Results

The data returned from `search_npi()` is organized according to its relationship to the NPI (`number` column). Data elements with a 1-to-1 relationship with NPI appear in vector columns, whereas elements with a many-to-1 relationship with NPI exist within [list columns](http://r4ds.had.co.nz/many-models.html#list-columns-1). Each element of a list column is a list of tibbles.

There are three such columns:

-   `taxonomies`: Service classification and licnese information
-   `addresses`: Location and mailing address information
-   `identifiers`: Miscellaneous provider identifiers and credential information

Any of these columns can be extracted as a tidy data frame using `dplyr::unnest()`:

``` r
tax <- res %>%
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
ids <- res %>%
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

By default, `search_npi()` will return at most 200 records per request, which is the maximum set by the API. To return additional records, specify the number of records to skip using the skip argument.

``` r
# Return records 200-400
search_npi(
  city = "San Francisco",
  state = "CA",
  skip = 200
  )
#> # A tibble: 200 x 33
#>        number enumeration_type created_epoch       last_updated_epoch 
#>         <int> <chr>            <dttm>              <dttm>             
#>  1 1487646758 NPI-1            2005-08-21 17:00:00 2013-03-03 16:00:00
#>  2 1427040732 NPI-1            2005-08-21 17:00:00 2018-03-19 17:00:00
#>  3 1417940685 NPI-1            2005-08-22 17:00:00 2016-06-06 12:55:07
#>  4 1003808338 NPI-1            2005-08-22 17:00:00 2008-12-10 16:00:00
#>  5 1609868934 NPI-1            2005-08-22 17:00:00 2007-07-07 17:00:00
#>  6 1942293071 NPI-2            2005-08-23 17:00:00 2007-07-07 17:00:00
#>  7 1891172219 NPI-1            2015-05-04 17:00:00 2015-05-05 15:07:36
#>  8 1639162514 NPI-1            2005-08-24 17:00:00 2012-09-17 17:00:00
#>  9 1245223031 NPI-1            2005-08-25 17:00:00 2007-07-07 17:00:00
#> 10 1689667495 NPI-1            2005-08-25 17:00:00 2014-03-18 17:00:00
#> # ... with 190 more rows, and 29 more variables: taxonomies <list>,
#> #   addresses <list>, identifiers <list>, status <chr>, credential <list>,
#> #   first_name <chr>, last_name <chr>, last_updated <chr>, name <chr>,
#> #   gender <chr>, sole_proprietor <chr>, name_prefix <chr>,
#> #   enumeration_date <chr>, middle_name <chr>, name_suffix <chr>,
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
