#' Construct an \code{npi_results} S3 object
#'
#' Creates an \code{npi_results} S3 object from a tibble. See \code{\link{validate_npi_results}} for other requirements for this class.
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



#' Validate input as S3 \code{npi_results} object
#'
#' Accepts an object, \code{x}, and determines whether it meets the criteria to be an S3 \code{npi_results} S3 object. The criteria include tests for data types, column names, and class attributes. They are intentionally strict to provide a contract to functions that interact with it.
#' @seealso \code{\link{new_npi_results}}
#' @keywords internal
validate_npi_results <- function(x, ...) {
  obj_types <- c("integer", "character", rep("list", 7),
                 rep("double", 2))
  obj_col_names <- c("npi", "enumeration_type", "basic",
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



#' Summary method for \code{npi_results} S3 object
#'
#' Print a human-readable overview of each record return in the results from a
#' call to \code{\link{search_npi}}. The format of the summary is modeled after
#' the one offered on the NPI registry website.
#'
#' @param object An \code{npi_results} S3 object
#' @param ... Additional optional arguments
#' @return Tibble containing the following columns:
#'   \describe{
#'     \item{\code{npi}}{National Provider Identifier (NPI) number}
#'     \item{\code{name}}{Provider's first and last name for individual providers,
#'       organization name for organizational providers.}
#'     \item{\code{enumeration_type}}{Type of provider associated with the NPI,
#'       either "Individual" or "Organizational"}
#'     \item{\code{primary_practice_address}}{Full address of the provider's
#'       primary practice location}
#'     \item{\code{phone}}{Provider's telephone number}
#'     \item{\code{primary_taxonomy}}{Primary taxonomy description}
#'   }
#' @examples
#' \dontrun{
#'  atl <- search_npi(city = "Atlanta")
#'  summary(atl)
#' }
#' @importFrom rlang .data
#' @export
summary.npi_results <- function(object, ...) {
  basic <- get_list_col(object, "basic")
  address_loc <- get_list_col(object, "addresses") %>%
    dplyr::filter(.data$addresses_address_purpose == "LOCATION") %>%
    dplyr::mutate(
      postal_code = hyphenate_full_zip(.data$addresses_postal_code)
    )

  # Some NPI records have only one taxonomy row with primary == FALSE;
  # include these along with those where primary == TRUE
  tax_primary <- get_list_col(object, "taxonomies") %>%
    dplyr::group_by(.data$npi) %>%
    dplyr::mutate(n_primary = sum(.data$taxonomies_primary == TRUE)) %>%
    dplyr::filter(.data$taxonomies_primary == TRUE | .data$n_primary == 0)

  tibble::tibble(
    npi = object$npi,
    name = ifelse(object$enumeration_type == "Individual",
                  paste(basic$basic_first_name, basic$basic_last_name),
                  basic$basic_organization_name),
    enumeration_type = object$enumeration_type,
    primary_practice_address = address_loc %>%
      make_full_address("addresses_address_1",
                        "addresses_address_2",
                        "addresses_city",
                        "addresses_state",
                        "addresses_postal_code"),
    phone = address_loc$addresses_telephone_number,
    primary_taxonomy = tax_primary$taxonomies_desc
  )
}



#' Flatten NPI search results
#'
#' This function takes an \code{npi_results} S3 object returned by
#' \code{\link{search_npi}} and flattens its list columns. It unnests the
#' lists columns and left joins them by \code{npi}. You can optionally specify
#' which columns from \code{df} to include.
#'
#' @details The names of unnested columns are prefixed by the name of their
#' originating list column to avoid name clashes and show their lineage. List
#' columns containing all NULL data will be absent from the result because there
#' are no columns to unnest.
#'
#' @param df A data frame containing the results of a call to
#'   \code{\link{search_npi}}.
#' @param cols If non-NULL, only the named columns specified here will be be
#'   flattened and returned along with \code{npi}.
#' @param key A quoted column name from \code{df} to use as a matching key. The
#'   default value is \code{"npi"}.
#' @return A data frame (tibble) with flattened list columns.
#' @examples
#' # Flatten all list columns
#' data(npis)
#' flatten_npi(npis)
#'
#' # Only flatten specified columns
#' flatten_npi(npis, cols = "basic")
#' flatten_npi(npis, cols = c("basic", "identifiers"))
#' @export
flatten_npi.npi_results <- function(df, cols = NULL, key = "npi") {
  validate_npi_results(df)

  if (!is.null(cols)) {
    df <- df[, c(key, cols)]
  }

  list_cols <- names(Filter(is.list, df))

  out <- lapply(list_cols, function(x) get_list_col(df, x))
  out <- Reduce(function(x, y) merge(x, y, by = key, all.x = TRUE), out)
  tibble::as.tibble(out)
}



#' S3 method to flatten an \code{npi_results} object
#' @inheritParams flatten_npi.npi_results
#' @export
flatten_npi <- function(df, cols, key) {
  UseMethod("flatten_npi")
}
