#' Sample results from the NPI Registry
#'
#' A dataset containing 10 records returned from an NPI Registry search
#' for providers with a primary address in New York City.
#'
#' \code{search_npi(city = "New York City", limit = 10)}
#'
#' @format A tibble with 10 rows and 11 columns, organized as follows:
#' \describe{
#'   \item{npi}{[integer] 10-digit National Provider Identifier number}
#'   \item{enumeration_type}{[character] Type of provider NPI, either
#'     "Individual" or "Organizational".}
#'   \item{basic}{[list of 1 tibble] Basic information about the provider.}
#'   \item{other_names}{[list of 0-n tibbles] Other names the provider
#'     goes by.}
#'   \item{identifiers}{[list of 0-50 tibbles] Other identifiers linked to
#'     the NPI.}
#'   \item{taxonomies}{[list of 0-15 tibbles] Healthcare Provider Taxonomy
#'     classification.}
#'   \item{addresses}{[list of 2 tibbles] Addresses for the provider's
#'     primary practice location and primary mailing address.}
#'   \item{practice_locations}{[list of 0-n tibbles] Addresses for the
#'     provider's other practice locations.}
#'   \item{endpoints}{[list of 0-n tibbles] Details about provider's endpoints
#'     for health information exchange.}
#'   \item{created_date}{[datetime] Date NPI record was first created (UTC).}
#'   \item{last_updated_date}{[datetime] UTC timestamp of the last time the
#'     NPI record was updated.}
#' }
#' @source \url{https://npiregistry.cms.hhs.gov/registry/help-api}
"npis"
