context("test-extractors.R")

test_that("clean_credentials works as expected", {
  expect_error(clean_credentials(1L), "x must be a character vector")
  expect_equal(clean_credentials(c("M.D.", "Ph.D.", "MD, Ph.D.")),
                                 list("MD", "PhD", c("MD", "PhD")))
})

test_address <- npi:::res$addresses[[2]][1, ]

test_that("address extractor works", {
  expect_equal(make_full_address(test_address, "address_1", "address_2", "city", "state", "postal_code"), "115 WEST 27TH STREET 4TH FLOOR, NEW YORK CITY, NY 100016217")
})
