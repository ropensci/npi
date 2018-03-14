context("test-extractors.R")

test_that("get_npi returns a zero-length numeric vector when non-npi_api object is provided as an argument", {
  expect_equal(get_npi("foo"), vector(mode = "numeric"))
})

test_that("get_npi returns a zero-length numeric vector when non-npi_api object is provided as an argument", {
  expect_message(get_npi("foo"), 'get_results expects an object of class "npi_api"')
})

npivec <- c(1598295529, 1710977137, 1346224904, 1336125137, 1588634661)

test_that("get_npi returns correct vector of npi numbers", {
  expect_equal(get_npi(npi:::res), npivec)
})
