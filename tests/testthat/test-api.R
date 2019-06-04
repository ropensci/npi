context("test-api.R")

test_that("search_npi provides messages when provider_type value is incorrect", {
  expect_message(search_npi(provider_type = "NPI1"))
})

multi_error <- "field state requires additional search criteria\nError: enumeration_type requires additional search criteria"

test_that("search_npi returns multi-line error messages from API", {
  expect_error(search_npi(provider_type = 1, state = "CA"), multi_error)
})

# Set arguments for search to be reused multiple times
my_search <- purrr::partial(search_npi, state = "RI", first_name = "Mary")

test_that("search_npi prevents requesting too-frequent reattempts", {
  expect_error(my_search(sleep = 0.9))
})

test_that("search_npi prevents requesting too many reattemts", {
  expect_error(my_search(n_tries = 11))
  expect_error(my_search(n_tries = 0))
})
