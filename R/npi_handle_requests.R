#' Control API requests
#'
#' Gets the maximum number of records allowed by the API in the fewest number
#' of requests.
#'
#' @param params A list of query parameters.
#' @return A list of API responses.
#' @keywords internal
npi_handle_requests <- function(params) {
  max_records <- params[["limit"]]
  request_limit <- 200

  # What's the max number of requests we'll have to make?
  max_requests <- ((max_records - 1) %/% request_limit) + 1
  results <- vector("list", max_requests)

  # Make requests until we've either reached the user's limit or
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
