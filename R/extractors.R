get_results <- function(responses) {
  if(!is.list(responses)) {
    abort_bad_argument("responses", must = "be list", not = responses)
  }

  if(any(purrr::map_chr(responses, class) != "nppes_api")) {
    rlang::abort(.subclass = "bad_class_error",
                 message = "All responses must have a `nppes_api` S3 class.")
  }

  responses %>%
    purrr::map("content") %>%
    unlist(recursive = FALSE)
}



pluck_vector_from_content <- function(content, col_name) {
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



new_npi_results <- function(x, ...) {
  checkmate::assert_tibble(x)

  structure(
    x,
    class = c("npi_results", "tbl_df", "tbl", "data.frame")
  )
}



validate_npi_results <- function(x, ...) {
  obj_types <- c("integer", "character", rep("list", 7),
                 rep("double", 2))
  obj_col_names <- c("npi", "provider_type", "basic",
                     "other_names", "identifiers",
                     "taxonomies", "addresses",
                     "practice_locations", "endpoints",
                     "created_date", "last_updated_date")

  # Ensure type- and column-safety
  checkmate::assert_tibble(x, types = obj_types, ncols = 11)

  if(!identical(names(x), obj_col_names)) {
    rlang::abort("Columns names do not match expected names.",
                 "bad_names_error")
  }

  # `npi_results` has to be the first element of the class
  # vector for generic methods to work.
  if("npi_results" != class(x)[[1]]) {
    rlang::abort("`x` is missing `npi_results` class.",
                 "bad_class_error")
  }

  x
}



list_to_tibble <- function(content, col_name, depth = 1L) {
  checkmate::assert_choice(depth, choices = c(1L, 2L))

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
#' @examples
#' # Load sample data
#' nyc <- npi:::res
#'
#' # Get basic list column by NPI
#' get_list_col(nyc, basic, npi)
#' get_list_col(nyc, taxonomies, npi)
#' @export
get_list_col <- function(df, list_col, key) {
  if (!is.data.frame(df)) {
    abort_bad_argument(arg = "df", must = "be data frame", not = df)
  }

  list_col <- dplyr::enquo(list_col)
  key <- dplyr::enquo(key)

  df %>%
    dplyr::select(!!key, !!list_col) %>%
    tidyr::unnest(!!list_col)
}



#' #' Flatten NPI search results
#' #'
#' #' This function takes a data frame produced by `search_npi()` and returns a data frame with several list columns flattened. It left joins the data frame by `npi` (NPI number) to the unnested list columns. The function adds suffixes to non-key columns with identical names to avoid name clashes and identify the source of unnested columns.
#' #'
#' #' @param df data frame containing the results of a call to `search_npi()`
#' #' @param key quoted column name from \code{df} to use as a matching key
#' #' @return data frame (tibble) with flattened list columns
#' flatten_results <- function(df, key) {
#'   if (!is.data.frame(df)) {
#'     abort_bad_argument(arg = "df", must = "be data frame", not = df)
#'   }
#'
#'   list_cols <- df %>%
#'     dplyr::select_if(is.list) %>%
#'     names() %>%
#'     rlang::syms()
#'
#'   lst <- list_cols %>%
#'     purrr::map(~ get_list_col(df, !!.x, key)) %>%
#'     magrittr::set_names(list_cols)
#'
#'   lst %>%
#'     purrr::reduce(dplyr::left_join, by = key)
#' }
