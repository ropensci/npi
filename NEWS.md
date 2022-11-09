npi 0.2.0 (2022-11-08)
========================

### MINOR IMPROVEMENTS

  * `npi_flatten()` is now covered by unit tests (#15 and #73).
  * `npi_search()` provides an informative error message when internet is off or the endpoint is unreachable (#52).
  * `npi_search()` now checks for legal use of special characters prior to submitting an API request (#53).
  * `npi_search()` now checks for legal use of wildcard characters prior to submitting an API request (#54).
  * User agent default now includes the installed package version (e.g., "npi/0.2.0") (#55).
  * `checkmate` package is now in Imports rather than Suggests so tests are run on it (#57).
  * `npi_search()` now has test coverage for the case where empty results are returned (#59).
  * `npi_search()` now provides a message indicating how many records are being requested (#72).
  * `npi_search()` now handles epoch field conversion to date format, fixing a breaking API change. Thanks to @trang-n for reporting the problem (#74) and @parmsam for submitting a PR that fixed it (#75).

### BUG FIXES

  * `npi_summarize()` now handles NPI records in which all provider taxonomy records have been flagged as non-primary (#51).
  * User functions are now backwards-compatible with `tidyr` <= 0.8.99 (#56).
  

### DOCUMENTATION FIXES

  * Grouped the reference index to highlight the most important functions (#45).
  * Added API URL to DESCRIPTION file (#47).
  * Clarified description of the `npis` dataset (#48).
  * Added [Advanced Use](https://docs.ropensci.org/npi/articles/advanced-use.html) vignette (#49).
  * Clarified the API's rate limitation (#50).
  * Removed unused internal functions `delay_by()` and `remove_null()` (#58).
  * Acknowledged rOpenSci reviewers, [Emily Zabore](https://github.com/zabore) (#63) and [Mattias Grenié](https://github.com/Rekyt), in DESCRIPTION. Thanks! (#60)
  * README now clarifies that `enumeration_type` is returned, not `provider_type` (#64).
  * README warns that code results in README may not be reproducible since they reflect dynamic, stateful data (#65).
  * Vignettes organize search arguments by name instead of description (#66).
  * `npi` vignette details what `npi_summarize()` (#67) and `npi_flatten()` (#68) do.
  * REAMDE and `npi` vignette provide use cases for `npi_is_valid()` (#69).
  * `npi_search()` documentation now links to the NPPES data dictionary to help users understand the API results (#70).


npi 0.1.0 (2020-03-03)
=========================

### MINOR IMPROVEMENTS

  * Added package website
  * Added introductory vignette (#13) (#29) @parmsam
  * Added example to documentation of each exported function (#32)
  * `npi_is_valid()` now uses the checkLuhn package for Luhn checking (#34)
  * `tidyr::unnest()` now works with old and new versions of tidyr 

### DOCUMENTATION FIXES

  * Updated redirected URLs to new targets
