context("test-api.R")

test_that("search_api provides messages when provider_type value is incorrect", {
  expect_message(search_npi(provider_type = "NPI1"),
                 '"provider_type" must be one of "NPI-1" or "NPI-2"')
#  expect_error(search_npi(number = 1234567890),
#               "NPI is not valid. Please supply a valid NPI.")
})
