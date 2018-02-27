#' Search the NPI Registry
#'
#' Wrapper function to search the U.S. National Provider Identifier (NPI) Registry using search parameters exposed by the registry's API.
#'
#' @param number The NPI Number is the unique 10-digit National Provider Identifier assigned to the provider.
#' @param enumeration_type The Read API can be refined to retrieve only Individual Providers or Organizational Providers. When it is not specified, both Type 1 and Type 2 NPIs will be returned. When using the Enumeration Type, it cannot be the only criteria entered. Additional criteria must also be entered as well. Valid values are: NPI-1: Individual Providers (Type 1) NPIs; NPI-2: Organizational Providers (Type 2) NPIs
#' @param taxonomy_description Search for providers by their taxonomy by entering the taxonomy description.
#' @param first_name This field only applies to Individual Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered (e.g. "jo*" ). This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param last_name This field only applies to Individual Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered. This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param organization_name This field only applies to Organizational Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered. This field allows the following special characters: ampersand, apostrophe,"at" sign, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon. Both the Organization Name and Other Organization Name fields associated with an NPI are examined for matching contents, therefore, the results might contain an organization name different from the one entered in the Organization Name criterion.
#' @param address_purpose Refers to whether the address information entered pertains to the provider's Mailing Address or the provider's Practice Location Address. When not specified, the results will contain the providers where either the Mailing Address or the Practice Location Addresses match the entered address information. Valid values are: "LOCATION", "MAILING"
#' @param city The City associated with the provider's address identified in Address Purpose. To search for a Military Address enter either APO or FPO into the City field. This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param state The State abbreviation associated with the provider's address identified in Address Purpose. This field cannot be used as the only input criterion. If this field is used, at least one other field, besides the Enumeration Type and Country, must be populated. Valid values for states: https://npiregistry.cms.hhs.gov/registry/API-State-Abbr
#' @param postal_code The Postal Code associated with the provider's address identified in Address Purpose. There is an implied trailing wildcard. If you enter a 5 digit postal code, it will match any appropriate 9 digit (zip+4) codes in the data.
#' @param country_code The Country associated with the provider's address identified in Address Purpose. This field can be used as the only input criterion as long as the value selected is not US (United States). Valid values for country codes: https://npiregistry.cms.hhs.gov/registry/API-Country-Abbr
#' @param limit Limit the results returned. The default value is 10; however, the value can be set to any value from 1 to 200.
#' @param skip The first N (value entered) results meeting the entered criteria will be bypassed and will not be included in the output.
#' @param pretty When checked, the response will be displayed in an easy to read format.
#'
#' @export
search_npi <-
  function(number = NULL,
           enumeration_type = NULL,
           taxonomy_description = NULL,
           first_name = NULL,
           last_name = NULL,
           organization_name = NULL,
           address_purpose = NULL,
           city = NULL,
           state = NULL,
           postal_code = NULL,
           country_code = NULL,
           limit = NULL,
           skip = NULL,
           pretty = NULL) {
    args <-
      list(
        number = number,
        enumeration_type = enumeration_type,
        taxonomy_description = taxonomy_description,
        first_name = first_name,
        last_name = last_name,
        organization_name = organization_name,
        address_purpose = address_purpose,
        city = city,
        state = state,
        postal_code = postal_code,
        country_code = country_code,
        limit = limit,
        skip = skip,
        pretty = pretty
      )
    # Check that at least one argument is not null
    attempt::stop_if_all(
      args,
      is.null,
      "You need to specify at least one argument"
    )
    # Check for internet
    check_internet()
    # Create and execute the request
    res <- httr::GET(base_url, query = purrr::compact(args))
    # Check the result
    check_status(res)
    # Get the content and return it as a data.frame
    jsonlite::fromJSON(rawToChar(res$content))$results
  }
