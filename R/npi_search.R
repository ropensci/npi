#' Search the NPI Registry
#'
#' Wrapper function to search the U.S. National Provider Identifier (NPI)
#' Registry using search parameters exposed by the registry's API (Version 2.1). If necessary, multiple requests are made. Results are combined and returned as a tibble with an S3 class of \code{npi_results}. See \code{Value} below for a description of the returned object.
#'
#' @details
#' By default, the function requests up to 10 records, but the \code{limit} argument accepts values from 1 to the API's limit of 1200.
#'
#' @param number (Optional) 10-digit NPI number assigned to the provider.
#' @param enumeration_type (Optional) Type of provider associated with the NPI,
#'   one of:
#'     \describe{
#'       \item{"ind"}{Individual provider (NPI-1)}
#'       \item{"org"}{Organizational provider (NPI-2)}
#'       }
#' @param taxonomy_description (Optional) Scalar character vector with a
#'   taxonomy description or code from the \href{http://nucc.org/index.php/code-sets-mainmenu-41/provider-taxonomy-mainmenu-40/code-lookup-mainmenu-50}{NUCC Healthcare Provider Taxonomy}.
#' @param first_name (Optional) This field only applies to Individual Providers. Trailing
#'   wildcard entries are permitted requiring at least two characters to be
#'   entered (e.g. "jo*" ). This field allows the following special characters:
#'   ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right
#'   parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param last_name (Optional) This field only applies to Individual Providers. Trailing
#'   wildcard entries are permitted requiring at least two characters to be
#'   entered. This field allows the following special characters: ampersand,
#'   apostrophe, colon, comma, forward slash, hyphen, left and right
#'   parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param use_first_name_alias (Optional) This field only applies to Individual Providers
#'   when not doing a wildcard search. When set to "True", the search results
#'   will include Providers with similar First Names. E.g., first_name=Robert,
#'   will also return Providers with the first name of Rob, Bob, Robbie, Bobby,
#'   etc. Valid Values are: TRUE: Will include alias/similar names; FALSE: Will
#'   only look for exact matches.
#' @param organization_name (Optional) This field only applies to Organizational Providers.
#'   Trailing wildcard entries are permitted requiring at least two characters
#'   to be entered. This field allows the following special characters:
#'   ampersand, apostrophe, "at" sign, colon, comma, forward slash, hyphen, left
#'   and right parentheses, period, pound sign, quotation mark, and semi-colon.
#'   Both the Organization Name and Other Organization Name fields associated
#'   with an NPI are examined for matching contents, therefore, the results
#'   might contain an organization name different from the one entered in the
#'   Organization Name criterion.
#' @param address_purpose Refers to whether the address information entered
#'   pertains to the provider's Mailing Address or the provider's Practice
#'   Location Address. When not specified, the results will contain the
#'   providers where either the Mailing Address or any of Practice Location
#'   Addresses match the entered address information. Primary will only search
#'   against Primary Location Address. While Secondary will only search against
#'   Secondary Location Addresses. Valid values are: "location", "mailing",
#'   "primary", "secondary".
#' @param city The City associated with the provider's address identified in
#'   Address Purpose. To search for a Military Address enter either APO or FPO
#'   into the City field. This field allows the following special characters:
#'   ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right
#'   parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param state The State abbreviation associated with the provider's address
#'   identified in Address Purpose. This field cannot be used as the only input
#'   criterion. If this field is used, at least one other field, besides the
#'   Enumeration Type and Country, must be populated. Valid values for states:
#'   \url{https://npiregistry.cms.hhs.gov/registry/API-State-Abbr}
#' @param postal_code The Postal Code associated with the provider's address
#'   identified in Address Purpose. If you enter a 5 digit postal code, it will
#'   match any appropriate 9 digit (zip+4) codes in the data. Trailing wildcard
#'   entries are permitted requiring at least two characters to be entered
#'   (e.g., "21*").
#' @param country_code The Country associated with the provider's address
#'   identified in Address Purpose. This field can be used as the only input
#'   criterion as long as the value selected is not US (United States). Valid
#'   values for country codes:
#'   \url{https://npiregistry.cms.hhs.gov/registry/API-Country-Abbr}
#' @param limit Maximum number of records to return, from 1 to 1200 inclusive.
#'   The default is 10. Because the API returns up to 200 records per request,
#'   values of \code{limit} greater than 200 will result in multiple API calls.

#' @return Data frame (tibble) containing the results of the search.
#' @references
#'   \url{https://npiregistry.cms.hhs.gov/registry/help-api}
#' @references
#'   \href{http://nucc.org/index.php/code-sets-mainmenu-41/provider-taxonomy-mainmenu-40/code-lookup-mainmenu-50}{NUCC Healthcare Provider Taxonomy}
#' @export
npi_search <- function(number = NULL,
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
                       limit = 10) {

  if (!is.null(enumeration_type) &&
      !enumeration_type %in% c("ind", "org")) {
    rlang::abort("`enumeration_type` must be one of: NULL, 'ind', or 'org'.")
  }

  enumeration_type <- ifelse(enumeration_type == "ind", "NPI-1", "NPI-2")

  if (!is.logical(use_first_name_alias) &&
      !is.null(use_first_name_alias)) {
    rlang::abort("`use_first_name_alias` must be TRUE or FALSE if specified.")
  }

  if (!is.null(use_first_name_alias)) {
    use_first_name_alias <- ifelse(isTRUE(use_first_name_alias),
                                   "True", "False")
  }

  if (!is.null(address_purpose)) {
    vals <- c("location", "mailing", "primary", "secondary")
    if (!address_purpose %in% vals) {
      msg <- paste("`address_purpose` must be one of:",
                   stringr::str_c(vals, collapse = ", "))
      rlang::abort(msg)
    }
  }

  # Validate `limit`
  if (limit < 1L || limit > 1200) {
    rlang::abort("`limit` must be a number between 1 and 1200.")
  }

  query <- list(
    version = API_VERSION,
    number = number,
    enumeration_type = enumeration_type,
    taxonomy_description = taxonomy_description,
    first_name = first_name,
    last_name = last_name,
    use_first_name_alias = use_first_name_alias,
    organization_name = organization_name,
    address_purpose = address_purpose,
    city = city,
    state = state,
    postal_code = postal_code,
    country_code = country_code,
    limit = limit
  )

  query %>%
    npi_handle_requests() %>%
    get_results() %>%
    tidy_results() %>%
    clean_results() %>%
    new_npi_results() %>%
    validate_npi_results()
}
