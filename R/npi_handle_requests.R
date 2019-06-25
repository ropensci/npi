#' Send API requests
#'
#' Sends API requests and stores the responses in a list.
#'
#' @param results A list of query results.
#' @return A list of API results.
#' @noRd
npi_requestor <- function(results = list(), ...) {
  msg <- glue::glue(
    "Requesting records {...$skip}-{...$skip + ...$limit}...")
  rlang::inform("status_pre_request", message = msg)

  result <- npi_get(npi_url(), query = ...)

  # Avoid an endless loop when the API returns no records
  if (length(result) == 0L) {
    rlang::abort("no_records_error", message = "No records returned.")
  }

  msg <- glue::glue("{length(result)} records returned\n")
  rlang::inform("status_post_request", message = msg)

  append(results, list(result))
}



#' Page API requests
#'
#' Gets the maximum number of records allowed by the API in the fewest number
#' of requests.
#'
#' @param params A list of query parameters.
#' @param user_n A scalar integer representing the maximum number of records the user requested.
#' @param results A list of request results
#' @return A final list of API results.
#' @noRd
npi_pager <- function(params, user_n, results = list()) {
  max_n_per_request <- 200L

  last_n_returned <-
    ifelse(length(results) > 0L, length(utils::tail(results, 1)[[1]]), 0L)

  tot_n_returned <- sum(vapply(results, length, integer(1L)))
  n_remaining <- user_n - tot_n_returned

  if (n_remaining == 0L ||
      (last_n_returned > 0L && last_n_returned < max_n_per_request)) {
    return(results)
  }

  # Modify `params` with newly calculated pagination values for request
  skip <- tot_n_returned
  limit <- ifelse(n_remaining < max_n_per_request, n_remaining, max_n_per_request)
  params <- utils::modifyList(params, list(limit = limit, skip = skip))

  # Send the request, recursively calling npi_pager() until termination
  results <- npi_requestor(results = results, query = params)
  Sys.sleep(1.5)
  npi_pager(params = params, user_n = user_n, results = results)
}
