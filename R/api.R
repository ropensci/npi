#' National Provider Identifier API client
#'
#' API client to the U.S. National Provider Identifier (NPI) public registry.
#'
#' @param query List of query parameters
#' @return \code{npi_api} S3 class containing the API content, URL, and response.
#' @export
npi_api <- function(query) {

  url <- httr::modify_url(base_url, query = query)
  ua <- httr::user_agent(user_agent)

  resp <- httr::GET(url, ua)
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <-
    jsonlite::fromJSON(httr::content(resp, "text", encoding = "utf8"),
                       simplifyVector = FALSE)

  if (status_code(resp) != 200) {
    stop(
      sprintf(
        "NPPES API request failed [%s]\n%s\n<%s>",
        status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = FALSE
    )
  }

  res <- structure(list(
    content = parsed,
    url = url,
    response = resp
  ),
  class = "npi_api")

  if (!is.null(res$content$Errors)) {
    msg <- purrr::map_chr(res$content$Errors, ~ .x)
    message(msg)
    return(dplyr::data_frame())
  }

  res

}

#' Print method for npi_api S3 class
#'
#' Print the structure of the content in an \code{npi_api} S3 class object.
#'
#' @param x npi_api S3 class object
#' @param ... Optional arguments
#'
#' @export
print.npi_api <- function(x, ...) {
  cat("<NPI ", x$url, ">\n", sep = "")
  utils::str(x$content)
  invisible(x)
}


#' Search the NPI Registry
#'
#' Wrapper function to search the U.S. National Provider Identifier (NPI) Registry using search parameters exposed by the registry's API.
#'
#' @param npi 10-digit National Provider Identifier number assigned to the provider.
#' @param provider_type The API can be refined to retrieve only Individual Providers or Organizational Providers. When it is not specified, both Type 1 and Type 2 NPIs will be returned. When using the Enumeration Type, it cannot be the only criteria entered. Additional criteria must also be entered as well. Valid values are: NPI-1: Individual Providers (Type 1) NPIs; NPI-2: Organizational Providers (Type 2) NPIs
#' @param taxonomy Search for providers by their taxonomy by entering the taxonomy description.
#' @param first_name This field only applies to Individual Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered (e.g. "jo*" ). This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param last_name This field only applies to Individual Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered. This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param org_name This field only applies to Organizational Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered. This field allows the following special characters: ampersand, apostrophe, "at" sign, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon. Both the Organization Name and Other Organization Name fields associated with an NPI are examined for matching contents, therefore, the results might contain an organization name different from the one entered in the Organization Name criterion.
#' @param address_purpose Refers to whether the address information entered pertains to the provider's Mailing Address or the provider's Practice Location Address. When not specified, the results will contain the providers where either the Mailing Address or the Practice Location Addresses match the entered address information. Valid values are: "LOCATION", "MAILING"
#' @param city The City associated with the provider's address identified in Address Purpose. To search for a Military Address enter either APO or FPO into the City field. This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param state The State abbreviation associated with the provider's address identified in Address Purpose. This field cannot be used as the only input criterion. If this field is used, at least one other field, besides the Enumeration Type and Country, must be populated. Valid values for states: https://npiregistry.cms.hhs.gov/registry/API-State-Abbr
#' @param postal_code The Postal Code associated with the provider's address identified in Address Purpose. There is an implied trailing wildcard. If you enter a 5 digit postal code, it will match any appropriate 9 digit (zip+4) codes in the data.
#' @param country_code The Country associated with the provider's address identified in Address Purpose. This field can be used as the only input criterion as long as the value selected is not US (United States). Valid values for country codes: https://npiregistry.cms.hhs.gov/registry/API-Country-Abbr
#' @param limit Limit the results returned. The default value is 10; however, the value can be set to any value from 1 to 200.
#' @param skip The first N (value entered) results meeting the entered criteria will be bypassed and will not be included in the output.
#'
#' @return \code{npi_api} S3 class containing the API content, URL, and response.
#' @export
search_npi <-
  function(npi = NULL,
           provider_type = NULL,
           taxonomy = NULL,
           first_name = NULL,
           last_name = NULL,
           org_name = NULL,
           address_purpose = NULL,
           city = NULL,
           state = NULL,
           postal_code = NULL,
           country_code = NULL,
           limit = 200,
           skip = NULL) {

    if (!is.null(provider_type)) {
      if (!provider_type %in% c(1, 2)) {
        message("provider_type must be one of: NULL, 1, or 2")
        return(dplyr::data_frame())
      }
    }

    provider_type <- ifelse(provider_type == 1, "NPI-1", "NPI-2")

    params <-
      list(
        number = npi,
        enumeration_type = provider_type,
        taxonomy_description = taxonomy,
        first_name = first_name,
        last_name = last_name,
        organization_name = org_name,
        address_purpose = address_purpose,
        city = city,
        state = state,
        postal_code = postal_code,
        country_code = country_code,
        limit = limit,
        skip = skip
      )

    npi_api(params)

  }
