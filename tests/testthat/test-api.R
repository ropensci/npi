context("test-api.R")

test_that("search_npi() messages when provider_type value is incorrect", {
  expect_error(search_npi(provider_type = "NPI1"),
               "provider_type must be one of: NULL, 1, or 2")
})

# nolint start
multi_error <- "field state requires additional search criteria\nError: enumeration_type requires additional search criteria"
# nolint end

# Set arguments for search to be reused multiple times
my_search <- purrr::partial(search_npi, state = "RI", first_name = "Mary")

test_that("search_npi() errors on invalid values of `limit`", {
  expect_error(search_npi(limit = -1))
  expect_error(search_npi(limit = 0))
  expect_error(search_npi(limit = 1201))
})

