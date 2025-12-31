# Changelog

## npi (development version)

### MINOR IMPROVEMENTS

- [`npi_search()`](../reference/npi_search.md) now normalizes
  `address_purpose` values to API constants and accepts case-insensitive
  input.
- [`npi_is_valid()`](../reference/npi_is_valid.md) now supports vector
  inputs and returns logical vectors.
- [`npi_search()`](../reference/npi_search.md) returns a typed empty
  `npi_results` object when no records are found.

### DOCUMENTATION FIXES

- Clarified [`npi_summarize()`](../reference/npi_summarize.md) taxonomy
  fallback behavior when no primary taxonomy is marked.

## npi 0.2.0

CRAN release: 2022-11-14

### MINOR IMPROVEMENTS

- [`npi_flatten()`](../reference/npi_flatten.md) is now covered by unit
  tests ([\#15](https://github.com/ropensci/npi/issues/15) and
  [\#73](https://github.com/ropensci/npi/issues/73)).
- [`npi_search()`](../reference/npi_search.md) provides an informative
  error message when internet is off or the endpoint is unreachable
  ([\#52](https://github.com/ropensci/npi/issues/52)).
- [`npi_search()`](../reference/npi_search.md) now checks for legal use
  of special characters prior to submitting an API request
  ([\#53](https://github.com/ropensci/npi/issues/53)).
- [`npi_search()`](../reference/npi_search.md) now checks for legal use
  of wildcard characters prior to submitting an API request
  ([\#54](https://github.com/ropensci/npi/issues/54)).
- User agent default now includes the installed package version (e.g.,
  “npi/0.2.0”) ([\#55](https://github.com/ropensci/npi/issues/55)).
- `checkmate` package is now in Imports rather than Suggests so tests
  are run on it ([\#57](https://github.com/ropensci/npi/issues/57)).
- [`npi_search()`](../reference/npi_search.md) now has test coverage for
  the case where empty results are returned
  ([\#59](https://github.com/ropensci/npi/issues/59)).
- [`npi_search()`](../reference/npi_search.md) now provides a message
  indicating how many records are being requested
  ([\#72](https://github.com/ropensci/npi/issues/72)).
- [`npi_search()`](../reference/npi_search.md) now handles epoch field
  conversion to date format, fixing a breaking API change. Thanks to
  [@trang-n](https://github.com/trang-n) for reporting the problem
  ([\#74](https://github.com/ropensci/npi/issues/74)) and
  [@parmsam](https://github.com/parmsam) for submitting a PR that fixed
  it ([\#75](https://github.com/ropensci/npi/issues/75)).

### BUG FIXES

- [`npi_summarize()`](../reference/npi_summarize.md) now handles NPI
  records in which all provider taxonomy records have been flagged as
  non-primary ([\#51](https://github.com/ropensci/npi/issues/51)).
- User functions are now backwards-compatible with `tidyr` \<= 0.8.99
  ([\#56](https://github.com/ropensci/npi/issues/56)).

### DOCUMENTATION FIXES

- Grouped the reference index to highlight the most important functions
  ([\#45](https://github.com/ropensci/npi/issues/45)).
- Added API URL to DESCRIPTION file
  ([\#47](https://github.com/ropensci/npi/issues/47)).
- Clarified description of the `npis` dataset
  ([\#48](https://github.com/ropensci/npi/issues/48)).
- Added [Advanced
  Use](https://docs.ropensci.org/npi/articles/advanced-use.html)
  vignette ([\#49](https://github.com/ropensci/npi/issues/49)).
- Clarified the API’s rate limitation
  ([\#50](https://github.com/ropensci/npi/issues/50)).
- Removed unused internal functions `delay_by()` and `remove_null()`
  ([\#58](https://github.com/ropensci/npi/issues/58)).
- Acknowledged rOpenSci reviewers, [Emily
  Zabore](https://github.com/zabore)
  ([\#63](https://github.com/ropensci/npi/issues/63)) and [Mattias
  Grenié](https://github.com/Rekyt), in DESCRIPTION. Thanks!
  ([\#60](https://github.com/ropensci/npi/issues/60))
- README now clarifies that `enumeration_type` is returned, not
  `provider_type` ([\#64](https://github.com/ropensci/npi/issues/64)).
- README warns that code results in README may not be reproducible since
  they reflect dynamic, stateful data
  ([\#65](https://github.com/ropensci/npi/issues/65)).
- Vignettes organize search arguments by name instead of description
  ([\#66](https://github.com/ropensci/npi/issues/66)).
- `npi` vignette details what
  [`npi_summarize()`](../reference/npi_summarize.md)
  ([\#67](https://github.com/ropensci/npi/issues/67)) and
  [`npi_flatten()`](../reference/npi_flatten.md)
  ([\#68](https://github.com/ropensci/npi/issues/68)) do.
- REAMDE and `npi` vignette provide use cases for
  [`npi_is_valid()`](../reference/npi_is_valid.md)
  ([\#69](https://github.com/ropensci/npi/issues/69)).
- [`npi_search()`](../reference/npi_search.md) documentation now links
  to the NPPES data dictionary to help users understand the API results
  ([\#70](https://github.com/ropensci/npi/issues/70)).

## npi 0.1.0 (2020-03-03)

### MINOR IMPROVEMENTS

- Added package website
- Added introductory vignette
  ([\#13](https://github.com/ropensci/npi/issues/13))
  ([\#29](https://github.com/ropensci/npi/issues/29))
  [@parmsam](https://github.com/parmsam)
- Added example to documentation of each exported function
  ([\#32](https://github.com/ropensci/npi/issues/32))
- [`npi_is_valid()`](../reference/npi_is_valid.md) now uses the
  checkLuhn package for Luhn checking
  ([\#34](https://github.com/ropensci/npi/issues/34))
- [`tidyr::unnest()`](https://tidyr.tidyverse.org/reference/unnest.html)
  now works with old and new versions of tidyr

### DOCUMENTATION FIXES

- Updated redirected URLs to new targets
