# Check if candidate NPI number is valid

Check whether a number is a valid NPI number per the specifications
detailed in the Final Rule for the Standard Unique Health Identifier for
Health Care Providers (69 FR 3434).

## Usage

``` r
npi_is_valid(x)
```

## Arguments

- x:

  10-digit candidate NPI number

## Value

Boolean indicating whether `npi` is valid

## Examples

``` r
npi_is_valid(1234567893) # TRUE
#> [1] TRUE
npi_is_valid(1234567898) # FALSE
#> [1] FALSE
```
