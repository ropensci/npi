#' get_results
#' @param npi_api List of parsed results from npi_api()
#' @return Tibble of cleaned search results
get_results <- function(npi_api) {
  if (purrr::is_empty(npi_api)) {
    message("Search returned no results.")
    return(dplyr::data_frame())
  }

  basic_cols <- purrr::map_df(npi_api, "basic")

  tax_cols <- npi_api %>%
    purrr::map( ~ .x$taxonomies) %>%
    purrr::map(purrr::map_df, ~ .x)

  address_cols <- npi_api %>%
    purrr::map( ~ .x$addresses) %>%
    purrr::map(purrr::map_df, ~ .x)

  id_cols <- npi_api %>%
    purrr::map( ~ .x$identifiers) %>%
    purrr::map(purrr::map_df, ~ .x)

  res <- npi_api %>%
    purrr::map_df(`[`,
                  c(
                    "number",
                    "enumeration_type",
                    "created_epoch",
                    "last_updated_epoch"
                  )) %>%
    dplyr::mutate(
      taxonomies = tax_cols,
      addresses = address_cols,
      identifiers = id_cols
    ) %>%
    dplyr::bind_cols(basic_cols)

  res$created_epoch <-
    as.POSIXct(res$created_epoch, origin = "1970-01-01")
  res$last_updated_epoch <-
    as.POSIXct(res$last_updated_epoch, origin = "1970-01-01")
  res$credential <- clean_credentials(res$credential)

  res
}
