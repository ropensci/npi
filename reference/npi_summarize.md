# S3 method to summarize an `npi_results` object

S3 method to summarize an `npi_results` object

## Usage

``` r
npi_summarize(object, ...)
```

## Arguments

- object:

  An `npi_results` S3 object

- ...:

  Additional optional arguments

## Value

Tibble containing the following columns:

- `npi`:

  National Provider Identifier (NPI) number

- `name`:

  Provider's first and last name for individual providers, organization
  name for organizational providers.

- `enumeration_type`:

  Type of provider associated with the NPI, either "Individual" or
  "Organizational"

- `primary_practice_address`:

  Full address of the provider's primary practice location

- `phone`:

  Provider's telephone number

- `primary_taxonomy`:

  Primary taxonomy description. If no taxonomy is marked as primary for
  a record, the first listed taxonomy is used.

## Examples

``` r
data(npis)
npi_summarize(npis)
#> # A tibble: 10 × 6
#>         npi name  enumeration_type primary_practice_add…¹ phone primary_taxonomy
#>       <int> <chr> <chr>            <chr>                  <chr> <chr>           
#>  1   1.19e9 ALYS… Individual       5 E 98TH ST FL SREET4… 212-… Physician Assis…
#>  2   1.31e9 MARK… Individual       16 PARK PL, NEW YORK,… 212-… Orthopaedic Sur…
#>  3   1.64e9 SAKS… Individual       10 E 102ND ST, NEW YO… 212-… Nurse Practitio…
#>  4   1.35e9 SARA… Individual       1335 DUBLIN RD STE 20… 614-… Occupational Th…
#>  5   1.56e9 AMY … Individual       1176 5TH AVE, NEW YOR… 212-… Psychiatry & Ne…
#>  6   1.79e9 NOAH… Individual       140 BERGEN STREET LEV… 973-… Internal Medici…
#>  7   1.56e9 ROBY… Individual       9 HOPE AVE STE 500, W… 781-… Nurse Practitio…
#>  8   1.96e9 LENO… Organization     100 E 77TH ST, NEW YO… 212-… Internal Medici…
#>  9   1.43e9 YONG… Individual       34 MAPLE ST, NORWALK,… 203-… Obstetrics & Gy…
#> 10   1.33e9 RAJE… Individual       12401 E 17TH AVE, AUR… 347-… Nurse Anestheti…
#> # ℹ abbreviated name: ¹​primary_practice_address
```
