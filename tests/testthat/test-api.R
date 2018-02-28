context("test-api.R")

test_that("search_api stops when no arguments are supplied", {
  expect_error(search_npi(), "Please specify at least one argument")
  expect_error(search_npi(number = 1234567890),
               "NPI is not valid. Please supply a valid NPI.")
})
