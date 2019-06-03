context("test-api.R")

test_that("search_npi provides messages when provider_type value is incorrect", {
  expect_message(search_npi(provider_type = "NPI1"))
})

test_that("search_npi returns error messages from API", {
  expect_error(search_npi(provider_type = 1))
})
