context("test-api.R")

test_that("search_npi() messages when provider_type value is incorrect", {
  expect_message(search_npi(provider_type = "NPI1"))
})

# nolint start
multi_error <- "field state requires additional search criteria\nError: enumeration_type requires additional search criteria"
# nolint end

# Set arguments for search to be reused multiple times
my_search <- purrr::partial(search_npi, state = "RI", first_name = "Mary")

test_that("search_npi() errors on invalid values of `limit`", {
  expect_message(my_search(limit = -1))
  expect_message(my_search(limit = 0))
  expect_message(my_search(limit = 1201))
})
