#' Construct request URL using BASE_URL
#'
#' @param ... Optional arguments for request
#' @return URL modified by any optional arguments passed to `...`
#' @noRd
npi_url <- function() {
  httr::modify_url(BASE_URL)
}



#' Specify configuration for API request
#'
#' User can set their own user agent as a value for the
#' `npi_user_agent` option via options().
#' @noRd
npi_config <- function() {
  httr::user_agent(
    getOption("npi_user_agent", default = USER_AGENT)
  )
}



#' Make generic API request and handle the response
#'
#' @param verb httr request verb such as GET, POST, etc.
#' @param url URL to which the request will be sent
#' @param config List of key-value configuration parameters
#' @param ... Optional arguments to be passed to `httr::modify_url()`
#' @return Response object or error
#' @noRd
npi_api <- function(verb, url, config = list(), ...) {
  FUN <- get(verb, envir = asNamespace("httr"))
  resp <- FUN(url, ..., config = c(npi_config(), config))
  npi_handle_response(resp)
}


#' Make a GET request to the API
#'
#' @noRd
npi_get <- function(url, ...) {
  npi_api("GET", url, ...)
}



#' Handle errors returned by the API
#'
#' Inspect API response object's status and handle business logic errors
#' returned by API.
#'
#' @param resp Response object from a REST API request
#' @return An error if present, otherwise the API response
#' @noRd
npi_handle_response <- function(resp) {
  resp_status <- httr::status_code(resp)
  resp_url <- resp$url

  if (resp_status >= 400L) {
    msg <- sprintf(
      "NPPES API request failed [%s]\n<%s>",
      resp_status,
      resp_url)

    rlang::abort("request_failed_error",
                 message = msg,
                 status = resp_status,
                 url = resp_url)
  }

  # The API may return other content types during maintenance,
  # and we need the response to be JSON.
  resp_http_type <- httr::http_type(resp)
  if (resp_http_type != "application/json") {
    msg <- paste0("API returned ", resp_http_type, ", not JSON.")
    rlang::abort("http_type_error", message = msg)
  }

  # The API returns structured errors, so let's print them nicely.
  errors <- httr::content(resp)$Errors

  if (!is.null(errors)) {
    pretty_errors <-
      purrr::map_chr(errors,
                     ~ paste0("\nField: ", .x$field, "\n", .x$description))

    msg <- stringr::str_c(pretty_errors, collapse = "\n\nError: ")
    rlang::abort("request_logic_error",
                 message = msg,
                 url = resp_url)
  }

  httr::content(resp)
}



#' Control API requests
#'
#' Get the maximum number of records allowed by the API
#' in the fewest requests.
#'
#' @param params List of query parameters
#' @return List of API responses
#' @noRd
npi_handle_requests <- function(params) {
  max_records <- params[["limit"]]
  request_limit <- 200

  # What's the max number of requests we'll have to make?
  max_requests <- ((max_records - 1) %/% request_limit) + 1
  results <- vector("list", max_requests)

  # Make requests until either we've hit the user's limit or
  # we get less than a multiple of the maximum number of records
  # that can be returned on a request.
  i <- 1
  total_records <- 0
  while ((total_records < max_records) &&
         (total_records %% request_limit == 0)) {
    curr_skip <- (i - 1) * request_limit
    remaining <- max_records - total_records
    curr_limit <- ifelse(
      remaining < request_limit,
      remaining,
      request_limit)

    curr_params <-
      utils::modifyList(params,
                        list(skip = curr_skip,
                             limit = curr_limit))

    # Pause to avoid hammering the API server
    # TODO: Reference specific record ranges
    if (i > 1L) {
      Sys.sleep(1L)
      message("Retrieving more records...")
    } else {
      message("Retrieving records...")
    }

    # TODO: handle errors gracefully so we don't lose successful requests
    results[[i]] <- npi_get(npi_url(), query = curr_params)
    paste0("npi_get(", npi_url(), ", query = ", curr_params)

    total_records <- total_records + results[[i]][["result_count"]]
    i <- i + 1
  }

  results
}


#' Search the NPI Registry
#'
#' Wrapper function to search the U.S. National Provider Identifier (NPI) Registry using search parameters exposed by the registry's API (Version 2.1). By default, the function submits up to six requests to obtain up to 1,200 NPI records, the maximum allowed by the API.
#'
#' @param number 10-digit National Provider Identifier number assigned to the provider.
#' @param enumeration_type The API can be refined to retrieve only Individual Providers or Organizational Providers. When it is not specified, both Type 1 and Type 2 NPIs will be returned. When using the Enumeration Type, it cannot be the only criteria entered. Additional criteria must also be entered as well. Valid values are: 'Ind': Individual Providers (Type 1) NPIs; 'Org': Organizational Providers (Type 2) NPIs.
#' @param taxonomy_description Search for providers by their taxonomy by entering the taxonomy description.
#' @param first_name This field only applies to Individual Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered (e.g. "jo*" ). This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param last_name This field only applies to Individual Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered. This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param use_first_name_alias This field only applies to Individual Providers when not doing a wildcard search. When set to "True", the search results will include Providers with similar First Names. E.g., first_name=Robert, will also return Providers with the first name of Rob, Bob, Robbie, Bobby, etc. Valid Values are: TRUE: Will include alias/similar names; FALSE: Will only look for exact matches.
#' @param organization_name This field only applies to Organizational Providers. Trailing wildcard entries are permitted requiring at least two characters to be entered. This field allows the following special characters: ampersand, apostrophe, "at" sign, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon. Both the Organization Name and Other Organization Name fields associated with an NPI are examined for matching contents, therefore, the results might contain an organization name different from the one entered in the Organization Name criterion.
#' @param address_purpose Refers to whether the address information entered pertains to the provider's Mailing Address or the provider's Practice Location Address. When not specified, the results will contain the providers where either the Mailing Address or any of Practice Location Addresses match the entered address information. Primary will only search against Primary Location Address. While Secondary will only search against Secondary Location Addresses. Valid values are: "location", "mailing", "primary", "secondary".
#' @param city The City associated with the provider's address identified in Address Purpose. To search for a Military Address enter either APO or FPO into the City field. This field allows the following special characters: ampersand, apostrophe, colon, comma, forward slash, hyphen, left and right parentheses, period, pound sign, quotation mark, and semi-colon.
#' @param state The State abbreviation associated with the provider's address identified in Address Purpose. This field cannot be used as the only input criterion. If this field is used, at least one other field, besides the Enumeration Type and Country, must be populated. Valid values for states: https://npiregistry.cms.hhs.gov/registry/API-State-Abbr
#' @param postal_code The Postal Code associated with the provider's address identified in Address Purpose. If you enter a 5 digit postal code, it will match any appropriate 9 digit (zip+4) codes in the data. Trailing wildcard entries are permitted requiring at least two characters to be entered (e.g., "21*").
#' @param country_code The Country associated with the provider's address identified in Address Purpose. This field can be used as the only input criterion as long as the value selected is not US (United States). Valid values for country codes: https://npiregistry.cms.hhs.gov/registry/API-Country-Abbr
#' @param limit Maximum number of records to return, from 1 to 1200 inclusive. The default is 10. Because the API returns up to 200 records per request, values of \code{limit} greater than 200 will result in multiple API calls.
#' @return Data frame (tibble) containing the results of the search.
#' @references \url{https://npiregistry.cms.hhs.gov/registry/help-api}
#' @export
search_npi <- function(number = NULL,
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



#' Summary method for npi_results S3 objects
#'
#' Modeled after summary profile presented on the NPPES registry
#' website.
#'
#' @param object `npi_results` S3 object
#' @param ... Additional optional arguments
#' @return Tibble containing the following columns: `npi`, `name`, `enumeration_type`, `primary_practice_address`, `phone`, and `primary_taxonomy`.
#' @importFrom rlang .data
#' @export
summary.npi_results <- function(object, ...) {
  basic <- get_list_col(object, .data$basic, .data$npi)
  address_loc <- get_list_col(object, .data$addresses, .data$npi) %>%
    dplyr::filter(.data$address_purpose == "LOCATION") %>%
    dplyr::mutate(
      postal_code = hyphenate_full_zip(.data$postal_code)
    )

  # Some NPI records have only one taxonomy row with primary == FALSE;
  # include these along with those where primary == TRUE
  tax_primary <- get_list_col(object, .data$taxonomies, .data$npi) %>%
    dplyr::group_by(.data$npi) %>%
    dplyr::mutate(n_primary = sum(.data$primary == TRUE)) %>%
    dplyr::filter(.data$primary == TRUE | .data$n_primary == 0)

  tibble::tibble(
    npi = object$npi,
    name = ifelse(object$enumeration_type == "Individual",
                  paste(basic$first_name, basic$last_name),
                  basic$organization_name),
    enumeration_type = object$enumeration_type,
    primary_practice_address = address_loc %>%
      make_full_address("address_1", "address_2", "city",
                        "state", "postal_code"),
    phone = address_loc$telephone_number,
    primary_taxonomy = tax_primary$desc
  )
}
