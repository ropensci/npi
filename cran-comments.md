# npi 0.3.1

This patch release fixes pagination when the API returns an empty final page,
preserves provider keys while flattening empty nested data, handles missing
optional address lines, and enforces the documented `npi_results` column types.
Tests and vignettes no longer require live API access during package checks.

## R CMD check results

`R CMD check --as-cran` on R 4.6.1 (aarch64-apple-darwin23, macOS Tahoe
26.6.2, 2026-09-05) reported:

0 errors | 0 warnings | 0 notes

The complete test suite passed on R 4.4.2 and R 4.6.1. The changed files pass
the configured linters, and `urlchecker::url_check()` reported that all URLs
are correct.

## Win-builder and reverse dependencies

Win-builder R-devel validation is pending upload. The service currently reports
the R-devel upload form as unavailable; submit the archive when that service is
available and record the returned R version, platform, timestamp, and status.

No CRAN reverse dependencies were found in a fresh CRAN metadata query on
2026-09-05, so no reverse-dependency checks are required.
