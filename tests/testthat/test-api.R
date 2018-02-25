context("test-api.R")

test_that("search_api stops when no arguments are supplied", {
  expect_error(search_npi(), "You need to specify at least one argument")
})
