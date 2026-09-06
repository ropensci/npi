# Validate input as S3 `npi_results` object

Accepts an object, `x`, and determines whether it meets the criteria to
be an S3 `npi_results` S3 object. The criteria include tests for data
types, column names, and class attributes. They are intentionally strict
to provide a contract to functions that interact with it. The NPI column
must be integer, enumeration type must be character, and the seven
nested columns must be lists. Both timestamp columns must be
double-backed `POSIXct` vectors. Missing values are permitted.

## Usage

``` r
validate_npi_results(x, ...)
```

## See also

[`new_npi_results`](new_npi_results.md)
