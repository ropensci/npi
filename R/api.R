#' Construct request URL using BASE_URL
#'
#' @return The value of BASE_URL set internally in \code{R/utils.R}
#' @keywords internal
npi_url <- function() {
  httr::modify_url(BASE_URL)
}



#' Specify configuration for API request
#'
#' User can set their own user agent as a value for the
#' `npi_user_agent` option via options(). See \pkg{npi} for an example.
#' @keywords internal
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
#' @keywords internal
npi_api <- function(verb, url, config = list(), ...) {
  FUN <- get(verb, envir = asNamespace("httr"))
  resp <- FUN(url, ..., config = c(npi_config(), config))
  npi_handle_response(resp)
}



#' Make a GET request to the API
#'
#' @keywords internal
npi_get <- function(url, ...) {
  npi_api("GET", url, ...)
}



#' Handle errors returned by the API
#'
#' Inspects the API response object's status and handle problems as follows:
#'   \itemize{
#'     \item Status codes of 400 or greater throw a \code{request_failed_error}
#'     \item Responses that do not return json content throw a
#'       \code{http_type_error}
#'     \item Responses containing other errors from the API throw a
#'       \code{request_logic_error}
#'   }
#' @param resp Response object from a REST API request
#' @return An error if present, otherwise the API response
#' @keywords internal
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
