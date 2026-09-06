if (!requireNamespace("pkgload", quietly = TRUE)) {
  stop("The pkgload package is required for the API smoke test.")
}

pkgload::load_all(".", quiet = TRUE)

number <- Sys.getenv("NPI_SMOKE_NUMBER", unset = "1013259613")

result <- tryCatch(
  npi_search(number = number, limit = 1L),
  error = function(error) {
    stop("The NPI API smoke request failed: ", conditionMessage(error), call. = FALSE)
  }
)

if (!inherits(result, "npi_results")) {
  stop("The NPI API response did not produce an npi_results object.", call. = FALSE)
}

required <- c("npi", "enumeration_type", "created_date", "last_updated_date")
if (!all(required %in% names(result))) {
  stop("The NPI API response is missing required result columns.", call. = FALSE)
}

if (nrow(result) < 1L || anyNA(result$npi)) {
  stop("The NPI API smoke lookup returned no usable NPI record.", call. = FALSE)
}

if (!inherits(result$created_date, "POSIXct") ||
    !inherits(result$last_updated_date, "POSIXct")) {
  stop("The NPI API response did not produce POSIXct timestamps.", call. = FALSE)
}

cat("NPI API smoke test passed: response shape and package parsing are healthy.\n")
