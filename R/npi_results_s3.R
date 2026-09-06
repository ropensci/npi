#' Construct an \code{npi_results} S3 object
#'
#' Creates an \code{npi_results} S3 object from a tibble. See
#'   \code{\link{validate_npi_results}} for other requirements for this class.
#'
#' @param x A tibble
#' @return A tibble with S3 class \code{npi_results}
#' @keywords internal
new_npi_results <- function(x, ...) {
  checkmate::assert_tibble(x)

  structure(
    x,
    class = c("npi_results", "tbl_df", "tbl", "data.frame")
  )
}

#' Construct an empty \code{npi_results} object
#'
#' @return A 0-row tibble with \code{npi_results} class
#' @noRd
new_empty_npi_results <- function() {
  new_npi_results(
    tibble::tibble(
      npi = integer(),
      enumeration_type = character(),
      basic = vector("list", 0),
      other_names = vector("list", 0),
      identifiers = vector("list", 0),
      taxonomies = vector("list", 0),
      addresses = vector("list", 0),
      practice_locations = vector("list", 0),
      endpoints = vector("list", 0),
      created_date = as.POSIXct(numeric(), origin = "1970-01-01", tz = "UTC"),
      last_updated_date = as.POSIXct(
        numeric(), origin = "1970-01-01", tz = "UTC"
      )
    )
  )
}



#' Validate input as S3 \code{npi_results} object
#'
#' Accepts an object, \code{x}, and determines whether it meets the criteria
#'   to be an S3 \code{npi_results} S3 object. The criteria include tests for
#'   data types, column names, and class attributes. They are intentionally
#'   strict to provide a contract to functions that interact with it.
#'   The NPI column must be integer, enumeration type must be character, and
#'   the seven nested columns must be lists. Both timestamp columns must be
#'   double-backed \code{POSIXct} vectors. Missing values are permitted.
#' @seealso \code{\link{new_npi_results}}
#' @keywords internal
validate_npi_results <- function(x, ...) {
  obj_types <- c(
    "integer", "character", rep("list", 7),
    rep("double", 2)
  )
  obj_col_names <- c(
    "npi", "enumeration_type", "basic",
    "other_names", "identifiers",
    "taxonomies", "addresses",
    "practice_locations", "endpoints",
    "created_date", "last_updated_date"
  )

  # Ensure type- and column-safety
  checkmate::assert_tibble(x, ncols = 11)

  if (!identical(names(x), obj_col_names)) {
    rlang::abort(
      "Columns names do not match expected names.",
      "bad_names_error"
    )
  }

  for (i in seq_along(obj_col_names)) {
    column <- obj_col_names[[i]]
    if (typeof(x[[column]]) != obj_types[[i]]) {
      rlang::abort(
        paste0("`", column, "` must have type ", obj_types[[i]], "."),
        "bad_type_error"
      )
    }
  }
  for (column in c("created_date", "last_updated_date")) {
    if (!inherits(x[[column]], "POSIXct")) {
      rlang::abort(
        paste0("`", column, "` must be a POSIXct vector."),
        "bad_type_error"
      )
    }
  }

  # `npi_results` has to be the first element of the class
  # vector for generic methods to work.
  if ("npi_results" != class(x)[[1]]) {
    rlang::abort(
      "`x` is missing `npi_results` class.",
      "bad_class_error"
    )
  }

  x
}


empty_npi_summary <- function() {
  tibble::tibble(
    npi = integer(),
    name = character(),
    enumeration_type = character(),
    primary_practice_address = character(),
    phone = character(),
    primary_taxonomy = character()
  )
}


add_missing_columns <- function(df, columns, default = NA_character_) {
  for (column in columns) {
    if (!column %in% names(df)) {
      df[[column]] <- rep(default, nrow(df))
    }
  }

  df
}



#' Summary method for \code{npi_results} S3 object
#'
#' Print a human-readable overview of each record return in the results from a
#' call to \code{\link{npi_search}}. The format of the summary is modeled after
#' the one offered on the NPI registry website.
#'
#' @param object An \code{npi_results} S3 object
#' @param ... Additional optional arguments
#' @return Tibble containing the following columns:
#'   \describe{
#'     \item{\code{npi}}{National Provider Identifier (NPI) number}
#'     \item{\code{name}}{Provider's first and last name for individual
#'     providers, organization name for organizational providers.}
#'     \item{\code{enumeration_type}}{Type of provider associated with the NPI,
#'       either "Individual" or "Organizational"}
#'     \item{\code{primary_practice_address}}{Full address of the provider's
#'       primary practice location}
#'     \item{\code{phone}}{Provider's telephone number}
#'     \item{\code{primary_taxonomy}}{Primary taxonomy description. If no
#'       taxonomy is marked as primary for a record, the first listed taxonomy
#'       is used.}
#'   }
#' @details Missing optional second address lines are treated as empty strings.
#'   Missing required address components leave the full address missing.
#' @examples
#' data(npis)
#' npi_summarize(npis)
#' @importFrom rlang .data
#' @export
npi_summarize.npi_results <- function(object, ...) {
  validate_npi_results(object)

  if (nrow(object) == 0L) {
    return(empty_npi_summary())
  }

  basic <- get_list_col(object, "basic") %>%
    add_missing_columns(
      c(
        "basic_first_name", "basic_last_name",
        "basic_organization_name"
      )
    ) %>%
    dplyr::group_by(.data$npi) %>%
    dplyr::slice_head(n = 1L) %>%
    dplyr::ungroup() %>%
    dplyr::select(
      "npi", "basic_first_name", "basic_last_name", "basic_organization_name"
    )

  address_loc <- get_list_col(object, "addresses") %>%
    add_missing_columns(
      c(
        "addresses_address_purpose", "addresses_address_1",
        "addresses_address_2", "addresses_city", "addresses_state",
        "addresses_postal_code", "addresses_telephone_number"
      )
    ) %>%
    dplyr::filter(.data$addresses_address_purpose == "LOCATION") %>%
    dplyr::mutate(
      addresses_postal_code = hyphenate_full_zip(.data$addresses_postal_code)
    )

  address_loc$primary_practice_address <- make_full_address(
    address_loc,
    "addresses_address_1",
    "addresses_address_2",
    "addresses_city",
    "addresses_state",
    "addresses_postal_code"
  )
  address_loc$phone <- address_loc$addresses_telephone_number

  address_loc <- address_loc %>%
    dplyr::group_by(.data$npi) %>%
    dplyr::slice_head(n = 1L) %>%
    dplyr::ungroup() %>%
    dplyr::select("npi", "primary_practice_address", "phone")

  # Some NPI records have only one taxonomy row with primary == FALSE;
  # include these along with those where primary == TRUE
  tax_primary <- get_list_col(object, "taxonomies") %>%
    add_missing_columns("taxonomies_primary", default = FALSE) %>%
    add_missing_columns("taxonomies_desc") %>%
    dplyr::group_by(.data$npi) %>%
    dplyr::mutate(n_primary = sum(.data$taxonomies_primary %in% TRUE)) %>%
    dplyr::filter(
      .data$taxonomies_primary %in% TRUE | .data$n_primary == 0L
    ) %>%
    dplyr::slice_head(n = 1L) %>%
    dplyr::ungroup() %>%
    dplyr::transmute(
      npi = .data$npi,
      primary_taxonomy = .data$taxonomies_desc
    )

  object %>%
    dplyr::select("npi", "enumeration_type") %>%
    dplyr::left_join(basic, by = "npi") %>%
    dplyr::mutate(
      name = ifelse(
        .data$enumeration_type == "Individual",
        stringr::str_c(.data$basic_first_name, " ", .data$basic_last_name),
        .data$basic_organization_name
      )
    ) %>%
    dplyr::left_join(address_loc, by = "npi") %>%
    dplyr::left_join(tax_primary, by = "npi") %>%
    dplyr::select(
      "npi", "name", "enumeration_type",
      "primary_practice_address", "phone", "primary_taxonomy"
    )
}



#' S3 method to summarize an \code{npi_results} object
#' @inheritParams npi_summarize.npi_results
#' @inherit npi_summarize.npi_results details
#' @return Tibble containing the following columns:
#'   \describe{
#'     \item{\code{npi}}{National Provider Identifier (NPI) number}
#'     \item{\code{name}}{Provider's first and last name for individual
#'     providers, organization name for organizational providers.}
#'     \item{\code{enumeration_type}}{Type of provider associated with the NPI,
#'       either "Individual" or "Organizational"}
#'     \item{\code{primary_practice_address}}{Full address of the provider's
#'       primary practice location}
#'     \item{\code{phone}}{Provider's telephone number}
#'     \item{\code{primary_taxonomy}}{Primary taxonomy description. If no
#'       taxonomy is marked as primary for a record, the first listed taxonomy
#'       is used.}
#'   }
#' @family summary functions
#' @examples
#' data(npis)
#' npi_summarize(npis)
#' @export
npi_summarize <- function(object, ...) {
  UseMethod("npi_summarize")
}



#' Flatten NPI search results
#'
#' This function takes an \code{npi_results} S3 object returned by
#' \code{\link{npi_search}} and flattens its list columns. It unnests the
#' lists columns and left joins them by \code{npi}. You can optionally specify
#' which columns from \code{df} to include.
#'
#' @details The names of unnested columns are prefixed by the name of their
#' originating list column to avoid name clashes and show their lineage. List
#' columns containing all NULL data will be absent from the result because there
#' are no columns to unnest.
#' All input keys are retained even when their selected nested data is empty,
#' regardless of the order of \code{cols}. If all selected nested data is empty,
#' only the keys are returned. When multiple nested tables have more than one
#' row for a key, their rows are combined in all possible combinations.
#'
#' @param df A data frame containing the results of a call to
#'   \code{\link{npi_search}}.
#' @param cols If non-NULL, only the named columns specified here will be be
#'   flattened and returned along with \code{npi}.
#' @param key A quoted column name from \code{df} to use as a matching key. The
#'   default value is \code{"npi"}.
#' @return A data frame (tibble) with flattened list columns.
#' @examples
#' # Flatten all list columns
#' data(npis)
#' npi_flatten(npis)
#'
#' # Only flatten specified columns
#' npi_flatten(npis, cols = c("basic", "identifiers"))
#' @export
npi_flatten.npi_results <- function(df, cols = NULL, key = "npi") {
  validate_npi_results(df)

  if (!is.null(cols)) {
    df <- df[, c(key, cols)]
  }

  list_cols <- names(Filter(function(x) {
    is.list(x) && any(vapply(x, length, integer(1L)) > 0L)
  }, df))

  out <- lapply(list_cols, function(x) {
    get_list_col(df, list_col = x, key = key)
  })
  keys <- unique(as.data.frame(df[key]))
  out <- Reduce(function(x, y) merge(x, y, by = key, all.x = TRUE),
                out, init = keys)
  tibble::as_tibble(out)
}



#' S3 method to flatten an \code{npi_results} object
#' @inheritParams npi_flatten.npi_results
#' @inherit npi_flatten.npi_results details
#' @return A data frame (tibble) with flattened list columns.
#' @family data wrangling functions
#' @examples
#' # Flatten all list columns
#' data(npis)
#' npi_flatten(npis)
#'
#' # Only flatten specified columns
#' npi_flatten(npis, cols = c("basic", "identifiers"))
#' @export
npi_flatten <- function(df, cols, key) {
  if (!inherits(df, "npi_results")) {
    abort_bad_argument(
      arg = "df",
      must = "be an npi_results S3 object",
      not = df,
      method = "class"
    )
  }

  UseMethod("npi_flatten")
}
