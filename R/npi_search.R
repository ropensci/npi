#' Search the NPI Registry
#'
#' Search the U.S. National Provider Identifier (NPI)
#' Registry using parameters exposed by the registry's API (Version 2.1).
#' Results are combined and returned
#' as a tibble with an S3 class of \code{npi_results}. See \code{Value} below
#' for a description of the returned object. API documentation may differ from
#' what is shown here. Consult \url{https://npiregistry.cms.hhs.gov/api-page}
#' for the latest documentation.
#'
#' @details By default, the function requests up to 10 records, but the
#' \code{limit} argument accepts values from 1 to the API's limit of 1200.
#'
#' @param number (Optional) 10-digit NPI number assigned to the provider.
#' @param enumeration_type (Optional) Type of provider associated with the NPI,
#'   one of: \describe{ \item{"ind"}{Individual provider (NPI-1)}
#'   \item{"org"}{Organizational provider (NPI-2)} }
#' @param taxonomy_description (Optional) Scalar character vector with an exact
#'   description or exact specialty or wildcard * after 2 characters from the
#'   \href{https://taxonomy.nucc.org}{NUCC Healthcare Provider Taxonomy}.
#' @param first_name (Optional) This field only applies to Individual Providers.
#'   Trailing wildcard entries are permitted requiring at least two characters
#'   to be entered (e.g. "jo*" ). This field allows the following special
#'   characters: ampersand, apostrophe, colon, comma, forward slash, hyphen,
#'   left and right parentheses, period, pound sign, quotation mark, and
#'   semi-colon.
#' @param last_name (Optional) This field only applies to Individual Providers.
#'   Trailing wildcard entries are permitted requiring at least two characters
#'   to be entered. This field allows the following special characters:
#'   ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right
#'   parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param use_first_name_alias (Optional) This field only applies to Individual
#'   Providers when not doing a wildcard search. When set to "True", the search
#'   results will include Providers with similar First Names. E.g.,
#'   first_name=Robert, will also return Providers with the first name of Rob,
#'   Bob, Robbie, Bobby, etc. Valid Values are: TRUE: Will include alias/similar
#'   names; FALSE: Will only look for exact matches.
#' @param organization_name (Optional) This field only applies to Organizational
#'   Providers. Trailing wildcard entries are permitted requiring at least two
#'   characters to be entered. This field allows the following special
#'   characters: ampersand, apostrophe, "at" sign, colon, comma, forward slash,
#'   hyphen, left and right parentheses, period, pound sign, quotation mark, and
#'   semi-colon. Both the Organization Name and Other Organization Name fields
#'   associated with an NPI are examined for matching contents, therefore, the
#'   results might contain an organization name different from the one entered
#'   in the Organization Name criterion.
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
#' @param limit Maximum number of records to return, from 1 to 1200 inclusive. The default is 10. Because the API returns up to 200 records per request, values of \code{limit} greater than 200 will result in multiple API calls.
#' @family search functions
#' @examples
#' \dontrun{
#' # 10 NPI records for New York City
#' npi_search(city = "New York City")
#'
#' # 1O NPI records for New York City, organizations only
#' npi_search(city = "New York City", enumeration_type = "org")
#'
#' # 1O NPI records for New York City, individuals only
#' npi_search(city = "New York City", enumeration_type = "ind")
#'
#' # 1200 NPI records for New York City
#' npi_search(city = "New York City", limit = 1200)
#'
#' # Nutritionists in Maine
#' npi_search(state = "ME", taxonomy_description = "Nutritionist")
#'
#' # Record associated with NPI 1245251222
#' npi_search(number = 1245251222)
#' }
#' @return Data frame (tibble) containing the results of the search.
#' @references
#'   \url{https://npiregistry.cms.hhs.gov/registry/help-api}
#'   \href{https://npiregistry.cms.hhs.gov/help-api/json-conversion}{Data dictionary for fields returned}
#' @references
#'   \href{https://taxonomy.nucc.org}{NUCC Healthcare Provider Taxonomy}
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
                       limit = 10L) {
  if (!is.null(enumeration_type) &&
      !enumeration_type %in% c("ind", "org")) {
    rlang::abort("`enumeration_type` must be one of: NULL, 'ind', or 'org'.")
  }

  enumeration_type <- ifelse(enumeration_type == "ind", "NPI-1", "NPI-2")

  # Check for illegal characters
  legal_1 <- "[^[:alnum:][:space:]()&:,-.#;'/\"\\*]"
  legal_2 <- "[^[:alnum:][:space:]()&:,-.#;'/\"@\\*]"

  if (any(stringr::str_detect(c(first_name, last_name, city), legal_1)) ||
      any(stringr::str_detect(organization_name, legal_2))) {
    msg <- "Field contains at least one illegal character. See `?npi_search`."
    rlang::abort(msg, class = "illegal_character")
  }

  if (!is.logical(use_first_name_alias) &&
      !is.null(use_first_name_alias)) {
    rlang::abort("`use_first_name_alias` must be TRUE or FALSE if specified.")
  }

  if (!is.null(use_first_name_alias)) {
    use_first_name_alias <- ifelse(isTRUE(use_first_name_alias), "True", "False")
  }

  if (!is.null(address_purpose)) {
    vals <- c("location", "mailing", "primary", "SECONDARY")
    if (!address_purpose %in% vals) {
      msg <- paste("`address_purpose` must be one of:",
                   stringr::str_c(vals, collapse = ", "))
      rlang::abort(msg)
    }
  }

  if (limit < 1L || limit > 1200) {
    rlang::abort("`limit` must be a number between 1 and 1200.")
  }

  # Validate wildcard rules on applicable fields
  wild_args <- list(taxonomy_description,
                    first_name,
                    last_name,
                    organization_name,
                    city,
                    postal_code)
  lapply(wild_args, function(x)
    if (!is.null(x))
      validate_wildcard_rules(x))

  npi_process_results(
    list(
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
  )
}



#' Processing pipeline for NPI search results
#' @noRd
npi_process_results <- function(params) {
  user_n <- params[["limit"]]

  msg <- glue::glue("{user_n} record", ifelse(user_n > 1, "s", ""), " requested")
  rlang::inform("status_pre_request", message = msg)

  results <- npi_control_requests(params, user_n)

  if (rlang::is_empty(results)) {
    return(tibble::tibble())
  }

  results %>%
    tidy_results() %>%
    clean_results() %>%
    new_npi_results() %>%
    validate_npi_results()
}
