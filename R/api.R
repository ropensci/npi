get_url <- function(query = NULL, url = NULL, ua = NULL, sleep = NULL) {
  url <- httr::modify_url(url, query = query)
  ua <- httr::user_agent(ua)

  Sys.sleep(sleep)

  resp <- httr::GET(url, ua)

  if (is.null(resp)) {
    rlang::abort("api_unavailable_error",
                 mesage = "Unable to reach API. Please try again later.")
  }

  resp
}



validate_response <- function(resp) {

  response_status <- httr::status_code(resp)
  request_url <- resp$url

  if (!identical(response_status, 200L)) {
    msg <- sprintf(
      "NPPES API request failed [%s]\n<%s>",
      response_status,
      request_url)

    rlang::abort("request_failed_error",
                 message = msg,
                 status = response_status,
                 url = request_url)
  }

  errors <- httr::content(resp)$Errors

  if (!is.null(errors)) {
    pretty_errors <- purrr::map_chr(errors, ~ paste0("\nField: ", .x$field,
                                           "\n", .x$description))
    msg <- stringr::str_c(pretty_errors, collapse = "\n\nError: ")
    rlang::abort("request_logic_error",
                 message = msg,
                 url = request_url)
  }

  resp
}



nppes_api <- function(query = NULL, url = BASE_URL, ua = USER_AGENT, sleep = 0L) {
  if (!is.list(query)) {
    abort_bad_argument("query", must = "be list", not = query)
  }

  if (!is.numeric(sleep) || sleep < 0L) {
    abort_bad_argument("sleep", must = "be a positive numeric.")
  }

  resp <- get_url(query = query, url = url, ua = ua, sleep = sleep)
  resp <- validate_response(resp)

  content <- httr::content(resp)$results
  path <- resp$url

  structure(
    list(
      content = content,
      path = path,
      response = resp
    ),
    class = "nppes_api"
  )
}


print.nppes_api <- function(x, ...) {
    cat("<NPPES ", x$path, ">\n", sep = "")
    utils::str(x$content)
    invisible(x)
  }



handle_requests <- function(params, req_limit = 200, sleep = 1L) {
  max_limit <- params$limit

  # Get maximum records allowed by API in fewest requests
  n_reqs <- ((max_limit - 1) %/% req_limit) + 1

  results <- list()

  for (req_no in 1:n_reqs) {
    # Calculate values of skip and limit parameters
    this_skip <- (req_no - 1) * req_limit
    this_remaining <- max_limit - this_skip
    this_limit <- ifelse(this_remaining <= req_limit,
                         this_remaining,
                         req_limit)
    params <- utils::modifyList(params,
                                list(skip = this_skip,
                                     limit = this_limit),
                                keep.null = FALSE)

    message("Retrieving records...")
    results[[req_no]] <- nppes_api(query = params, sleep= sleep)

    n_recs <- length(results[[req_no]]$content)
    if (n_recs < req_limit) {
      break
    }
  }

  results
}



#' Search the NPI Registry
#'
#' Wrapper function to search the U.S. National Provider Identifier (NPI) Registry using search parameters exposed by the registry's API (Version 2.1). By default, the function submits up to six requests to obtain up to 1,200 NPI records, the maximum allowed by the API.
#'
#' @param npi 10-digit National Provider Identifier number assigned to the provider.
#' @param provider_type The API can be refined to retrieve only Individual Providers or Organizational Providers. When it is not specified, both Type 1 and Type 2 NPIs will be returned. When using the Enumeration Type, it cannot be the only criteria entered. Additional criteria must also be entered as well. Valid values are: NPI-1: Individual Providers (Type 1) NPIs; NPI-2: Organizational Providers (Type 2) NPIs
#' @param taxonomy Search for providers by their taxonomy by entering the taxonomy description.
#' @param first_name This field only applies to Individual Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered (e.g. "jo*" ). This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param last_name This field only applies to Individual Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered. This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param use_first_name_alias This field only applies to Individual Providers when not doing a wildcard search. When set to "True", the search results will include Providers with similar First Names. E.g., first_name=Robert, will also return Providers with the first name of Rob, Bob, Robbie, Bobby, etc. Valid Values are: TRUE: Will include alias/similar names; FALSE: Will only look for exact matches.
#' @param org_name This field only applies to Organizational Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered. This field allows the following special characters: ampersand, apostrophe, "at" sign, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon. Both the Organization Name and Other Organization Name fields associated with an NPI are examined for matching contents, therefore, the results might contain an organization name different from the one entered in the Organization Name criterion.
#' @param address_purpose Refers to whether the address information entered pertains to the provider's Mailing Address or the provider's Practice Location Address. When not specified, the results will contain the providers where either the Mailing Address or any of Practice Location Addresses match the entered address information. Primary will only search against Primary Location Address. While Secondary will only search against Secondary Location Addresses. Valid values are: "location", "mailing", "primary", "secondary".
#' @param city The City associated with the provider's address identified in Address Purpose. To search for a Military Address enter either APO or FPO into the City field. This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param state The State abbreviation associated with the provider's address identified in Address Purpose. This field cannot be used as the only input criterion. If this field is used, at least one other field, besides the Enumeration Type and Country, must be populated. Valid values for states: https://npiregistry.cms.hhs.gov/registry/API-State-Abbr
#' @param postal_code The Postal Code associated with the provider's address identified in Address Purpose. If you enter a 5 digit postal code, it will match any appropriate 9 digit (zip+4) codes in the data. Trailing wildcard entries are permitted requiring at least two characters to be entered (e.g., "21*").
#' @param country_code The Country associated with the provider's address identified in Address Purpose. This field can be used as the only input criterion as long as the value selected is not US (United States). Valid values for country codes: https://npiregistry.cms.hhs.gov/registry/API-Country-Abbr
#' @param limit Maximum number of records to return, from 1 to 1200 inclusive. The default is 10. Because the API returns up to 200 records per request, values of \code{limit} greater than 200 will result in multiple API calls.
#' @return Data frame (tibble) containing the results of the search.
#' @references \url{https://npiregistry.cms.hhs.gov/registry/help-api}
#' @export
search_npi <-
  function(npi = NULL,
           provider_type = NULL,
           taxonomy = NULL,
           first_name = NULL,
           last_name = NULL,
           use_first_name_alias = NULL,
           org_name = NULL,
           address_purpose = NULL,
           city = NULL,
           state = NULL,
           postal_code = NULL,
           country_code = NULL,
           limit = 10) {

    if (!is.null(provider_type)) {
      if (!provider_type %in% c(1, 2)) {
        rlang::abort("provider_type must be one of: NULL, 1, or 2")
      }
    }

    provider_type <- ifelse(provider_type == 1, "NPI-1", "NPI-2")

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
      rlang::abort("`limit` must be a number between 1 and 1200")
    }

    params <- list(
      npi = npi,
      provider_type = provider_type,
      taxonomy = taxonomy,
      first_name = first_name,
      last_name = last_name,
      use_first_name_alias = use_first_name_alias,
      org_name = org_name,
      address_purpose = address_purpose,
      city = city,
      state = state,
      postal_code = postal_code,
      country_code = country_code,
      limit = limit
    )

    handle_requests(params) %>%
      get_results() %>%
      tidy_results() %>%
      clean_results()
  }
