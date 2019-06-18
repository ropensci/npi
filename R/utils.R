# Global variables for GET request
API_VERSION <- "2.1"
BASE_URL <- paste0("https://npiregistry.cms.hhs.gov/api/?version=", API_VERSION)
USER_AGENT <- "http://github.com/frankfarach/npi"


#' Abort bad function arguments
#'
#' Error handler to abort a bad argument based on its actual vs. expected type
#'
#' @param arg Function argument name as character vector
#' @param must Text to relate argument's name to its expected type
#' @param not Function argument's name
#' @return Error handler with templated message and metadata
abort_bad_argument <- function(arg, must, not = NULL) {
  msg <- glue::glue("`{arg}` must {must}")
  if (!is.null(not)) {
    not <- typeof(not)
    msg <- glue::glue("{msg}, not {not}.")
  }

  rlang::abort("error_bad_argument",
        message = msg,
        arg = arg,
        must = must,
        not = not
  )
}


#' Check if candidate NPI number is valid
#'
#' Check whether a number is a valid NPI number per the specifications detailed in the Final Rule for the Standard Unique Health Identifier for Health Care Providers (69 FR 3434).
#'
#' @param x 10-digit candidate NPI number
#' @return Boolean indicating whether \code{npi} is valid
#' @examples
#' is_valid_npi(1234567893)
#' is_valid_npi(1234567898)
#' @seealso \url{https://www.cms.gov/Regulations-and-Guidance/Administrative-Simplification/NationalProvIdentStand/Downloads/NPIcheckdigit.pdf}
#' @references \url{http://scott.sherrillmix.com/blog/tag/luhn-algorithm/}
#' @export
is_valid_npi <- function(x) {
  if (stringr::str_length(x) != 10 ||
      stringr::str_detect(x, "\\d{10}",
                          negate = TRUE)) {
    rlang::abort("`x` must be a 10-digit number.")
  }

  x <- as.character(x)

  # Prefix the NPI with code for US health applications per US governement
  # requirements
  x <- paste0("80840", x)

  # Validate number using the Luhn algorithm
  x <- gsub("[^0-9]", "", x)
  x <- as.integer(strsplit(x, "")[[1]])
  selector <- seq(length(x) - 1, 1, -2)
  x[selector] <- x[selector] * 2
  x[x > 9] <- x[x > 9] - 9
  remainder <- sum(x) %% 10
  remainder == 0
}



#' Clean up credentials
#'
#' @param x Character vector of credentials
#' @return List of cleaned character vectors, with one list element per element of \code{x}
clean_credentials <- function(x) {
  if (!is.character(x))
    stop("x must be a character vector")

  out <- gsub("\\.", "", x)
  out <- stringr::str_split(out, "[,\\s;]+", simplify = FALSE)
  out
}


#' Format United States (US) ZIP codes
#'
#' @param x Character vector
#'
#' @return Length \code{x} character vector hyphenated for ZIP+4 or 5-digit ZIP. Invalid elements of \code{x} are not formatted.
hyphenate_full_zip <- function(x) {
  checkmate::assert(
    checkmate::check_character(x),
    checkmate::check_integerish(x),
    combine = "or"
  )

  x <- as.character(x)

  # Add a hyphen in the right place iff the element has exactly 9 digits;
  # otherwise, leave the (possibly) invalid ZIP alone
  zip_regex <- "^[[:digit:]]{9}$"
  ifelse(
   stringr::str_detect(x, zip_regex),
   paste0(stringr::str_sub(x, 1, 5), "-", stringr::str_sub(x, 6, 9)),
   x)
}


#' Create full address from elements
#'
#' @param df Data frame
#' @param address_1 Quoted column name in \code{df} containing a character vector of first-street-line addresses
#' @param address_2 Quoted column name in \code{df} containing a character vector of second-street-line addresses
#' @param city Quoted column name in \code{df} containing a character vector of cities
#' @param state Quoted column name in \code{df} containing a character vector of two-letter state abbreviations
#' @param postal_code Quoted column name in \code{df} containing a character or numeric vector of postal codes
#'
#' @return Character vector containing full one-line addresses
make_full_address <-
  function(df,
           address_1,
           address_2,
           city,
           state,
           postal_code) {
    stopifnot(is.data.frame(df),
              all(c(
                address_1, address_2, city, state, postal_code
              ) %in% names(df)))

    stringr::str_c(
        stringr::str_trim(df[[address_1]], "both"),
        ifelse(df[[address_2]] == "", "", " "),
        stringr::str_trim(df[[address_2]], "both"),
        ", ",
        stringr::str_trim(df[[city]], "both"),
        ", ",
        stringr::str_trim(df[[state]], "both"),
        " ",
        stringr::str_trim(df[[postal_code]], "both")
      )
  }
