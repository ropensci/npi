# Suppress R CMD CHECK note about global variables in flatten_npi()
globalVariables(c("number", "taxonomies", "addresses", "identifiers"))

#' get_results
#' @param npi_api List of parsed results from npi_api()
#' @return Tibble of cleaned search results
get_results <- function(npi_api) {
  if (purrr::is_empty(npi_api)) {
    message("Search returned no results.")
    return(dplyr::tibble())
  }

  basic_cols <- npi_api %>%
    purrr::map("basic") %>%
    purrr::map(tibble::as_tibble)

  tax_cols <- npi_api %>% prep_list_col("taxonomies")
  address_cols <- npi_api %>% prep_list_col("addresses")
  id_cols <- npi_api %>% prep_list_col("identifiers")
  other_names_cols <- npi_api %>% prep_list_col("other_names")

  res <- npi_api %>%
    purrr::map_df(`[`,
                  c(
                    "number",
                    "enumeration_type",
                    "created_epoch",
                    "last_updated_epoch"
                  )) %>%
    dplyr::mutate(
      basic = basic_cols,
      other_names = other_names_cols,
      identifiers = id_cols,
      taxonomies = tax_cols,
      addresses = address_cols
    )

  res$created_epoch <-
    as.POSIXct(res$created_epoch, origin = "1970-01-01")
  res$last_updated_epoch <-
    as.POSIXct(res$last_updated_epoch, origin = "1970-01-01")

  ords <- c(1:2, 5:9, 3:4)

  res[, ords]
}


#' Package npi_api entries as list of cleaned dfs
#'
#' Cleaning includes turning all empty character strings to NAs
#'
#' @param npi_api Search result from search_npi
#' @param name Name of entity in search_npi result
#' @return List of tibbles corresponding to named element
prep_list_col <- function(npi_api, name) {

  empty_char_to_na <- purrr::as_mapper(~ dplyr::na_if(.x, ""))

  npi_api %>%
    purrr::map(name) %>%
    purrr::map(purrr::map_df, dplyr::bind_rows) %>%
    purrr::map(dplyr::mutate_if, is.character, empty_char_to_na)
}



#' Extract list column by key
#'
#' @param df data frame
#' @param list_col list column in \code{df}
#' @param key key column in \code{df}
#' @return data frame with \code{key} and unnested \code{list_col}
get_list_col <- function(df, list_col, key) {

  if (!is.data.frame(df))
    stop("`df` must be a data frame")

  list_col <- dplyr::enquo(list_col)
  key <- dplyr::enquo(key)

  df %>%
    dplyr::select(!!key, !!list_col) %>%
    tidyr::unnest(!!list_col)
}

#' Flatten NPI search results
#'
#' This function takes a data frame produced by `search_npi()` and returns a data fram with several list columns flattened. It left joins the data frame by `number` (NPI number) to the unnested list columns, "taxonomies", "addresses", and "identifiers". The function adds suffixes to non-key columns with identical names to avoid name clashes and identify the source of unnested columns.
#'
#' @param df data frame containing columns named "number", "taxonomies", "addresses", and "identifiers"
#' @return data frame (tibble) with flattened list columns
#' @export
flatten_npi <- function(df) {
  if (!is.data.frame(df))
    stop("`df` must be a data frame")

  cols <- c("number", "taxonomies", "addresses", "identifiers")

  if (any(!cols %in% names(df))) {
    msg <- paste("`df` must contain columns named", cols)
    stop(msg)
  }

  tax <- get_list_col(df, taxonomies, number)
  addr <- get_list_col(df, addresses, number)
  id <- get_list_col(df, identifiers, number)

  df <- df %>%
    dplyr::select(-taxonomies, -addresses, -identifiers)

  dplyr::left_join(df, tax, by = "number", suffix = c("", "_taxonomy")) %>%
    dplyr::left_join(addr, by = "number", suffix = c("", "_address")) %>%
    dplyr::left_join(id, by = "number", suffix = c("", "_id"))
}
