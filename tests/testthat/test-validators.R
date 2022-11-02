context("test-validators.R")

test_that("npi_is_valid() requires a 10-digit number", {
  expect_error(npi_is_valid())
  expect_error(npi_is_valid(123456789))
  expect_error(npi_is_valid("123456789A"))
})

test_that("npi_is_valid() uses the Luhn algorithm", {
  expect_true(npi_is_valid(1234567893))
  expect_false(npi_is_valid(1234567898))
})

test_that("hyphenate_full_zip() works correctly", {
  bad_zips_chr <- c(
    "902100201", "90210", "9021", "90210-", "90210-0",
    "90210-020"
  )
  expect_zips_chr <- c("90210-0201", bad_zips_chr[2:6])

  bad_zips_num <- c(902100201, 90210)
  expect_zips_num <- c("90210-0201", "90210")

  expect_equal(hyphenate_full_zip(bad_zips_num), expect_zips_num)
  expect_equal(hyphenate_full_zip(bad_zips_chr), expect_zips_chr)
})

test_that("validate_wildcard_rules() works correctly", {
  xs_pass <- c("Mall*", "Ma*", "M")
  xs_error <- c("Mal*l", "Mal**", "M**", "M*")
  xs_too_long <- c("a", "b")
  xs_not_char <- TRUE
  xs_numeric <- 23414

  expect_error(validate_wildcard_rules(xs_too_long), class = "bad_wildcard_error")
  expect_error(validate_wildcard_rules(xs_not_char), class = "bad_wildcard_error")
  expect_true(validate_wildcard_rules(xs_numeric))
  expect_equal(
    setNames(c(TRUE, TRUE, TRUE), xs_pass),
    vapply(
      xs_pass,
      FUN = function(x)
        validate_wildcard_rules(x),
      FUN.VALUE = logical(1L)
    )
  )
  lapply(xs_error,
         function(x)
           expect_error(validate_wildcard_rules(x), class = "bad_wildcard_error"))
})
