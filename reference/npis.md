# Sample results from the NPI Registry

A dataset containing 10 records returned from an NPI Registry search for
providers with a primary address in New York City.

## Usage

``` r
npis
```

## Format

A tibble with 10 rows and 11 columns, organized as follows:

- npi:

  \[integer\] 10-digit National Provider Identifier number

- enumeration_type:

  \[character\] Type of provider NPI, either "Individual" or
  "Organizational".

- basic:

  \[list of 1 tibble\] Basic information about the provider.

- other_names:

  \[list of tibbles\] Other names the provider goes by.

- identifiers:

  \[list of tibbles\] Other identifiers linked to the NPI.

- taxonomies:

  \[list of tibbles\] Healthcare Provider Taxonomy classification.

- addresses:

  \[list of tibbles\] Addresses for the provider's primary practice
  location and primary mailing address.

- practice_locations:

  \[list of tibbles\] Addresses for the provider's other practice
  locations.

- endpoints:

  \[list of tibbles\] Details about provider's endpoints for health
  information exchange.

- created_date:

  \[datetime\] Date NPI record was first created (UTC).

- last_updated_date:

  \[datetime\] UTC timestamp of the last time the NPI record was
  updated.

## Source

<https://npiregistry.cms.hhs.gov/registry/help-api>

## Details

`search_npi(city = "New York City", limit = 10)`
