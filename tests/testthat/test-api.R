context("test-api.R")

test_that("search_npi provides messages when provider_type value is incorrect", {
  expect_message(search_npi(provider_type = "NPI1"),
                 "provider_type must be one of: NULL, 1, or 2")
})

test_that("search_npi returns error messages from API", {
  expect_message(search_npi(provider_type = 1),
                 "Error 09 - enumeration_type requires additional search criteria")
})

test_that("search_npi returns an empty list when there are no results", {
  expect_identical(search_npi(postal_code = "zzz"), list())
})
