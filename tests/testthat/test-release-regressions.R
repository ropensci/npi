test_that("pagination preserves records and stops at the requested boundary", {
  cases <- list(
    c(available = 0L, limit = 10L, requests = 1L),
    c(available = 17L, limit = 300L, requests = 1L),
    c(available = 200L, limit = 201L, requests = 2L),
    c(available = 400L, limit = 401L, requests = 3L),
    c(available = 500L, limit = 200L, requests = 1L),
    c(available = 500L, limit = 201L, requests = 2L),
    c(available = 500L, limit = 400L, requests = 2L),
    c(available = 1200L, limit = 1200L, requests = 6L)
  )

  for (case in cases) {
    queries <- list()
    records <- lapply(seq_len(case[["available"]]), function(i) {
      list(
        number = as.character(1000000000L + i),
        enumeration_type = "NPI-1",
        basic = list(first_name = "Test", last_name = "Provider"),
        created_epoch = "1600000000000",
        last_updated_epoch = "1600000000000"
      )
    })
    controller <- npi_control_requests
    stub(controller, "npi_get_results", function(results, query) {
      queries[[length(queries) + 1L]] <<- query
      end <- min(length(records), query$skip + query$limit)
      page <- if (end > query$skip) {
        records[seq.int(query$skip + 1L, end)]
      } else {
        NULL
      }
      append(results, list(page))
    })
    stub(controller, "Sys.sleep", NULL)
    # Recursive calls use the local mock without changing the package.
    environment(controller)$npi_control_requests <- controller
    stub(npi_process_results, "npi_control_requests", controller)

    result <- suppressMessages(npi_process_results(list(
      version = "2.1", city = "Test City", limit = case[["limit"]]
    )))
    n <- min(case[["available"]], case[["limit"]])
    expect_identical(result$npi, 1000000000L + seq_len(n))
    expect_s3_class(result, "npi_results")
    expect_length(queries, case[["requests"]])
    expect_equal(vapply(queries, `[[`, numeric(1), "skip"),
                 (seq_along(queries) - 1L) * 200L)
    expect_equal(vapply(queries, `[[`, numeric(1), "limit"),
                 pmin(200L, case[["limit"]] -
                        (seq_along(queries) - 1L) * 200L))
    expect_true(all(vapply(queries, function(x) {
      identical(x$city, "Test City") && identical(x$version, "2.1")
    }, logical(1))))
    if (n == 0L) expect_identical(result, new_empty_npi_results())
  }
})

test_that("flattening preserves keys regardless of nested column order", {
  x <- npis[1:2, ]
  x$identifiers[[1]] <- tibble()
  x$identifiers[[2]] <- tibble(code = "ID")
  for (cols in list(c("identifiers", "basic"), c("basic", "identifiers"))) {
    result <- npi_flatten(x, cols = cols)
    expect_setequal(result$npi, x$npi)
    expect_true(is.na(result$identifiers_code[result$npi == x$npi[1]]))
  }
})

test_that("flattening empty nested data returns the input keys", {
  x <- npis[1:2, ]
  x$identifiers <- list(tibble(), tibble())
  x$other_names <- list(NULL, NULL)
  result <- npi_flatten(x, cols = c("identifiers", "other_names"))
  expect_named(result, "npi")
  expect_setequal(result$npi, x$npi)
  expect_equal(nrow(result), 2L)
  empty <- npi_flatten(new_empty_npi_results())
  expect_identical(empty, tibble(npi = integer()))
})

test_that("flattening retains custom keys and Cartesian combinations", {
  x <- npis[1:2, ]
  x$identifiers <- list(tibble(code = c("A", "B")), tibble())
  x$other_names <- list(tibble(name = c("X", "Y", "Z")), tibble())
  result <- npi_flatten(x, cols = c("identifiers", "other_names"))
  expect_equal(sum(result$npi == x$npi[1]), 6L)
  expect_equal(sum(result$npi == x$npi[2]), 1L)
  expected <- expand.grid(identifiers_code = c("A", "B"),
                          other_names_name = c("X", "Y", "Z"),
                          stringsAsFactors = FALSE)
  expect_setequal(paste(result$identifiers_code[1:6],
                        result$other_names_name[1:6]),
                  paste(expected$identifiers_code, expected$other_names_name))
  custom <- npi_flatten(x, cols = "identifiers", key = "enumeration_type")
  expect_named(custom, c("enumeration_type", "identifiers_code"))
  expect_equal(nrow(custom), 2L)
  expect_setequal(custom$identifiers_code, c("A", "B"))
})

test_that("summary addresses tolerate missing optional second lines", {
  x <- npis[rep(1L, 4), ]
  x$npi <- x$npi + seq_len(4L)
  address <- tibble(
    address_purpose = "LOCATION", address_1 = "1 MAIN ST",
    address_2 = "SUITE 2", city = "NEW YORK", state = "NY",
    postal_code = "10001"
  )
  x$addresses <- rep(list(address), 4)
  x$addresses[[1]]$address_2 <- NULL
  x$addresses[[2]]$address_2 <- NA_character_
  x$addresses[[3]]$address_2 <- ""
  result <- npi_summarize(x)
  expect_identical(result$primary_practice_address,
                   c(rep("1 MAIN ST, NEW YORK, NY 10001", 3),
                     "1 MAIN ST SUITE 2, NEW YORK, NY 10001"))
  expect_identical(npi_summarize(x[1, ])$primary_practice_address,
                   "1 MAIN ST, NEW YORK, NY 10001")
  x$addresses[[1]]$city <- NA_character_
  expect_true(is.na(npi_summarize(x)$primary_practice_address[1]))
})

test_that("result validation enforces each column's type and timestamp class", {
  expect_identical(validate_npi_results(npis), npis)
  empty <- new_empty_npi_results()
  expect_identical(validate_npi_results(empty), empty)
  for (column in names(npis)) {
    x <- npis
    x[[column]] <- if (column == "enumeration_type") {
      seq_len(nrow(x))
    } else {
      rep("wrong type", nrow(x))
    }
    expect_error(validate_npi_results(x), column)
  }
  for (column in c("created_date", "last_updated_date")) {
    x <- npis
    x[[column]] <- as.numeric(x[[column]])
    expect_error(validate_npi_results(x), column)
  }
  x <- npis
  names(x)[1] <- "wrong_name"
  expect_error(validate_npi_results(x), class = "bad_names_error")
  x <- tibble::as_tibble(npis)
  expect_error(validate_npi_results(x), class = "bad_class_error")
})
