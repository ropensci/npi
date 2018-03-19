context("test-validators.R")

test_that("is_valid_npi() requires a 10-digit number", {
  expect_error(is_valid_npi(), "Please supply an npi as the argument.")
  expect_error(is_valid_npi(123456789), "npi must be a 10-digit number.")
  expect_error(is_valid_npi("123456789A"), "npi must be a 10-digit number.")
})

test_that("is_valid_npi() uses the Luhn algorithm", {
  expect_true(is_valid_npi(1234567893))
  expect_false(is_valid_npi(1234567898))
})

test_that("hyphenate_full_zip() works correctly", {
  expect_equal(hyphenate_full_zip("902100201"), "90210-0201")
  expect_equal(hyphenate_full_zip("90210"), "90210")
  expect_equal(hyphenate_full_zip("902101"), "90210-1")
})
