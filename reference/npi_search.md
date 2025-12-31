# Search the NPI Registry

Search the U.S. National Provider Identifier (NPI) Registry using
parameters exposed by the registry's API (Version 2.1). Results are
combined and returned as a tibble with an S3 class of `npi_results`. See
`Value` below for a description of the returned object. API
documentation may differ from what is shown here. Consult
<https://npiregistry.cms.hhs.gov/api-page> for the latest documentation.

## Usage

``` r
npi_search(
  number = NULL,
  enumeration_type = NULL,
  taxonomy_description = NULL,
  first_name = NULL,
  last_name = NULL,
  use_first_name_alias = NULL,
  organization_name = NULL,
  address_purpose = NULL,
  city = NULL,
  state = NULL,
  postal_code = NULL,
  country_code = NULL,
  limit = 10L
)
```

## Arguments

- number:

  (Optional) 10-digit NPI number assigned to the provider.

- enumeration_type:

  (Optional) Type of provider associated with the NPI, one of:

  "ind"

  :   Individual provider (NPI-1)

  "org"

  :   Organizational provider (NPI-2)

- taxonomy_description:

  (Optional) Scalar character vector with an exact description or exact
  specialty or wildcard \* after 2 characters from the [NUCC Healthcare
  Provider Taxonomy](https://taxonomy.nucc.org).

- first_name:

  (Optional) This field only applies to Individual Providers. Trailing
  wildcard entries are permitted requiring at least two characters to be
  entered (e.g. "jo\*" ). This field allows the following special
  characters: ampersand, apostrophe, colon, comma, forward slash,
  hyphen, left and right parentheses, period, pound sign, quotation
  mark, and semi-colon.

- last_name:

  (Optional) This field only applies to Individual Providers. Trailing
  wildcard entries are permitted requiring at least two characters to be
  entered. This field allows the following special characters:
  ampersand, apostrophe, colon, comma, forward slash, hyphen, left and
  right parentheses, period, pound sign, quotation mark, and semi-colon.

- use_first_name_alias:

  (Optional) This field only applies to Individual Providers when not
  doing a wildcard search. When set to "True", the search results will
  include Providers with similar First Names. E.g., first_name=Robert,
  will also return Providers with the first name of Rob, Bob, Robbie,
  Bobby, etc. Valid Values are: TRUE: Will include alias/similar names;
  FALSE: Will only look for exact matches.

- organization_name:

  (Optional) This field only applies to Organizational Providers.
  Trailing wildcard entries are permitted requiring at least two
  characters to be entered. This field allows the following special
  characters: ampersand, apostrophe, "at" sign, colon, comma, forward
  slash, hyphen, left and right parentheses, period, pound sign,
  quotation mark, and semi-colon. Both the Organization Name and Other
  Organization Name fields associated with an NPI are examined for
  matching contents, therefore, the results might contain an
  organization name different from the one entered in the Organization
  Name criterion.

- address_purpose:

  Refers to whether the address information entered pertains to the
  provider's Mailing Address or the provider's Practice Location
  Address. When not specified, the results will contain the providers
  where either the Mailing Address or any of Practice Location Addresses
  match the entered address information. Primary will only search
  against Primary Location Address. While Secondary will only search
  against Secondary Location Addresses. Valid values are: "location",
  "mailing", "primary", "secondary".

- city:

  The City associated with the provider's address identified in Address
  Purpose. To search for a Military Address enter either APO or FPO into
  the City field. This field allows the following special characters:
  ampersand, apostrophe, colon, comma, forward slash, hyphen, left and
  right parentheses, period, pound sign, quotation mark, and semi-colon.

- state:

  The State abbreviation associated with the provider's address
  identified in Address Purpose. This field cannot be used as the only
  input criterion. If this field is used, at least one other field,
  besides the Enumeration Type and Country, must be populated. Valid
  values for states:
  <https://npiregistry.cms.hhs.gov/registry/API-State-Abbr>

- postal_code:

  The Postal Code associated with the provider's address identified in
  Address Purpose. If you enter a 5 digit postal code, it will match any
  appropriate 9 digit (zip+4) codes in the data. Trailing wildcard
  entries are permitted requiring at least two characters to be entered
  (e.g., "21\*").

- country_code:

  The Country associated with the provider's address identified in
  Address Purpose. This field can be used as the only input criterion as
  long as the value selected is not US (United States). Valid values for
  country codes:
  <https://npiregistry.cms.hhs.gov/registry/API-Country-Abbr>

- limit:

  Maximum number of records to return, from 1 to 1200 inclusive. The
  default is 10. Because the API returns up to 200 records per request,
  values of `limit` greater than 200 will result in multiple API calls.

## Value

Data frame (tibble) containing the results of the search.

## Details

By default, the function requests up to 10 records, but the `limit`
argument accepts values from 1 to the API's limit of 1200.

## References

<https://npiregistry.cms.hhs.gov/registry/help-api> [Data dictionary for
fields
returned](https://npiregistry.cms.hhs.gov/help-api/json-conversion)

[NUCC Healthcare Provider Taxonomy](https://taxonomy.nucc.org)

## Examples

``` r
if (FALSE) { # \dontrun{
# 10 NPI records for New York City
npi_search(city = "New York City")

# 1O NPI records for New York City, organizations only
npi_search(city = "New York City", enumeration_type = "org")

# 1O NPI records for New York City, individuals only
npi_search(city = "New York City", enumeration_type = "ind")

# 1200 NPI records for New York City
npi_search(city = "New York City", limit = 1200)

# Nutritionists in Maine
npi_search(state = "ME", taxonomy_description = "Nutritionist")

# Record associated with NPI 1245251222
npi_search(number = 1245251222)
} # }
```
