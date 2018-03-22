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

test_that("clean_credentials works as expected", {
  expect_error(clean_credentials(1L), "x must be a character vector")
  expect_equal(clean_credentials(c("M.D.", "Ph.D.", "MD, Ph.D.")),
                                 list("MD", "PhD", c("MD", "PhD")))
})

test_address <- npi:::res_df$addresses[[2]][1, ]

test_that("address extractor works", {
  expect_equal(make_full_address(test_address, "address_1", "address_2", "city", "state", "postal_code"), "115 WEST 27TH STREET 4TH FLOOR, NEW YORK CITY, NY 100016217")
})
