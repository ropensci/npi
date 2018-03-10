#' get_resultso
#' @param npi_api npi_api S3 object
#' @export
get_results <- function(npi_api) {
  if (!inherits(npi_api, "npi_api")) {
    message('get_results expects an object of class "npi_api"')
    return(tibble::data_frame())
  }

  res <- npi_api

  basic_cols <- purrr::map_df(res, "basic")

  tax_cols <- res %>%
    purrr::map( ~ .x$taxonomies) %>%
    purrr::map(purrr::map_df, ~ .x)

  address_cols <- res %>%
    purrr::map( ~ .x$addresses) %>%
    purrr::map(purrr::map_df, ~ .x)

  id_cols <- res %>%
    purrr::map( ~ .x$identifiers) %>%
    purrr::map(purrr::map_df, ~ .x)

  res <- res %>%
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

  res
}

#' get_npi
#' @param npi_api An `npi_api` S3 object
#' @export
get_npi <- function(npi_api) {
  if (!inherits(npi_api, "npi_api")) {
    message('get_results expects an object of class "npi_api"')
    return(tibble::data_frame())
  }

  npi_api %>%
    purrr::map_int("number")
}
