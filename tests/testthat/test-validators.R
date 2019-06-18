context("test-validators.R")

test_that("is_valid_npi() requires a 10-digit number", {
  expect_error(is_valid_npi())
  expect_error(is_valid_npi(123456789))
  expect_error(is_valid_npi("123456789A"))
})

test_that("is_valid_npi() uses the Luhn algorithm", {
  expect_true(is_valid_npi(1234567893))
  expect_false(is_valid_npi(1234567898))
})

test_that("hyphenate_full_zip() works correctly", {
  bad_zips_chr <- c("902100201", "90210", "9021", "90210-", "90210-0", "90210-020")
  expect_zips_chr<- c("90210-0201", bad_zips_chr[2:6])

  bad_zips_num <- c(902100201, 90210)
  expect_zips_num <- c("90210-0201", "90210")

  expect_equal(hyphenate_full_zip(bad_zips_num), expect_zips_num)
  expect_equal(hyphenate_full_zip(bad_zips_chr), expect_zips_chr)
})
