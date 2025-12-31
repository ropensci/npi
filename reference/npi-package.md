# npi: Access the U.S. National Provider Identifier Registry API

Access the United States National Provider Identifier Registry API
<https://npiregistry.cms.hhs.gov/api/>. Obtain and transform
administrative data linked to a specific individual or organizational
healthcare provider, or perform advanced searches based on provider
name, location, type of service, credentials, and other attributes
exposed by the API.

## Details

npi makes it easy to search and work with data from the U.S. National
Provider Identifier (NPI) Registry API (v2.1) directly from R. Obtain
rich administrative data linked to a specific individual or
organizational healthcare provider, or perform advanced searches based
on provider name, location, type of service, credentials, and many other
attributes. npi provides convenience functions for data extraction so
you can spend less time wrangling data and more time putting data to
work.

There are three functions you're likely to need from this package. The
first is [`npi_search`](npi_search.md), which allows you to query the
NPI Registry and returns up to 1,200 full NPI records as a data frame
(tibble). Next, you can use [`npi_summarize`](npi_summarize.md) on these
results to obtain a human-readable summary of each record. Finally,
[`npi_flatten`](npi_flatten.md) extracts and flattens
conceptually-related subsets of data into a tibble that are joined by
the \`npi\` column into an analysis-ready object.

## Package options

npi's default user agent is the URL of the package's GitHub repository,
<https://github.com/ropensci/npi>. You can customize it by setting the
`npi_user_agent` option:

`options(npi_user_agent = "your_user_agent_here")`

## See also

Useful links:

- <https://github.com/ropensci/npi/>

- <https://docs.ropensci.org/npi/>

- <https://npiregistry.cms.hhs.gov/api/>

- Report bugs at <https://github.com/ropensci/npi/issues/>

## Author

**Maintainer**: Frank Farach <frank.farach@gmail.com>
([ORCID](https://orcid.org/0000-0002-2145-0145)) \[copyright holder\]

Other contributors:

- Sam Parmar <parmartsam@gmail.com> \[contributor\]

- Matthias Grenié <matthias.grenie@idiv.de>
  ([ORCID](https://orcid.org/0000-0002-4659-7522)) \[reviewer\]

- Emily C. Zabor <zabore2@ccf.org>
  ([ORCID](https://orcid.org/0000-0002-1402-4498)) \[reviewer\]
