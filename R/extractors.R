get_results <- function(responses) {
  if(!is.list(responses)) {
    abort_bad_argument("responses", must = "be list", not = responses)
  }

  responses %>%
    purrr::map("content") %>%
    unlist(recursive = FALSE)
}



pluck_vector_from_content <- function(content, col_name = NULL) {
  content %>%
    purrr::map(purrr::pluck, col_name) %>%
    unlist(recursive = FALSE)
}



tidy_results <- function(content) {
  tibble::tibble(
    npi = pluck_vector_from_content(content, "number"),
    provider_type = pluck_vector_from_content(content, "enumeration_type"),
    basic = list_to_tibble(content, "basic"),
    other_names = list_to_tibble(content, "other_names", 2),
    identifiers = list_to_tibble(content, "identifiers", 2),
    taxonomies = list_to_tibble(content, "taxonomies", 2),
    addresses = list_to_tibble(content, "addresses", 2),
    practice_locations = list_to_tibble(content, "practice_locations", 2),
    endpoints = list_to_tibble(content, "endpoints", 2),
    created_date = pluck_vector_from_content(content, "created_epoch"),
    last_updated_date = pluck_vector_from_content(content, "last_updated_epoch")
  )
}



clean_results <- function(results) {
  epoch_to_date <- purrr::as_mapper(
    ~ as.POSIXct(.x, origin = "1970-01-01", tz = "UTC")
  )

  results %>%
    dplyr::mutate(
      provider_type = dplyr::case_when(
      provider_type == "NPI-1" ~ "Individual",
      provider_type == "NPI-2" ~ "Organization",
      TRUE                     ~ NA_character_)) %>%
    dplyr::mutate_at(dplyr::vars(dplyr::ends_with("_date")), epoch_to_date)
}



list_to_tibble <- function(content, col_name, depth = 1L) {
  if (depth < 1L || depth > 2L) {
    stop("`depth` must be the integer 1 or 2")
  }

  level_one <- content %>% purrr::map(col_name)

  if (depth == 1L) {
    out <- level_one %>% purrr::map(tibble::as_tibble)
    return(out)
  }

  level_one %>% purrr::map(purrr::map_df, dplyr::bind_rows)
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
#' This function takes a data frame produced by `search_npi()` and returns a data fram with several list columns flattened. It left joins the data frame by `npi` (NPI number) to the unnested list columns. The function adds suffixes to non-key columns with identical names to avoid name clashes and identify the source of unnested columns.
#'
#' @param df data frame containing columns named "number", "taxonomies", "addresses", and "identifiers"
#' @return data frame (tibble) with flattened list columns
#' @export
flatten_results <- function(df) {
  if (!is.data.frame(df))
    stop("`df` must be a data frame")

  list_cols <- df %>%
    dplyr::select_if(is.list) %>%
    names() %>%
    rlang::syms()

  lst <- list_cols %>%
    purrr::map(~ get_list_col(df, !!.x, npi)) %>%
    magrittr::set_names(list_cols)

  lst %>%
    purrr::reduce(dplyr::left_join, by = "npi")
}
