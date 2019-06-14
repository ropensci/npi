context("test-api.R")

library(httptest)


# Global variables for GET request
API_VERSION <- "2.1"
BASE_URL <- paste0("https://npiregistry.cms.hhs.gov/api/?version=", API_VERSION)
USER_AGENT <- "http://github.com/frankfarach/npi"


with_mock_api({
  test_that("Requests happen with the correct URL and user agent", {
    npi <- "1437187390"
    req <- get_url(query = list(number = npi), url = BASE_URL,
                   ua = USER_AGENT, sleep = 0L)
    expect_is(req, "response")
    expect_identical(req$url, paste0(BASE_URL, "&number=", npi))
    expect_identical(req$request$options$useragent, USER_AGENT)
  })
})


test_that("get_url() rejects invalid values supplied to arguments", {
  test_get_url <- purrr::partial(get_url, url = BASE_URL, ua = USER_AGENT)
  expect_error(test_get_url(query = "foo", sleep = 0),
               class = "error_bad_argument")
  expect_error(test_get_url(query = list(provider_type = 1), sleep = 0),
               class = "error_bad_argument")
  expect_error(test_get_url(query = list(provider_type = 1), sleep = -1),
               class = "error_bad_argument")
})


with_mock_api({
  test_that("Response validation catches logic errors returned by API", {
    req <- get_url(query = list(provider_type = 1), url = BASE_URL,
                   ua = USER_AGENT, sleep = 0L)
    expect_error(validate_response(unclass(req)),
                 "`resp` class must be `response`, not list.")
    expect_error(validate_response(req), .subclass = "request_logic_error")
  })
})


# with_mock_api({
#   test_that("nppes_api() returns an object with class `nppes_api`", {
#     req <- nppes_api(query = list(provider_type = 1,
#                                   city = "Atlanta",
#                                   limit = 2),
#                      url = BASE_URL,
#                      ua = USER_AGENT)
#     expect_is(req, "nppes_api")
#   })
# })


test_that("search_npi() messages when provider_type value is incorrect", {
  expect_error(search_npi(provider_type = "NPI1"),
               "provider_type must be one of: NULL, 1, or 2")
})

# nolint start
multi_error <- "field state requires additional search criteria\nError: enumeration_type requires additional search criteria"
# nolint end

# Set arguments for search to be reused multiple times
my_search <- purrr::partial(search_npi, state = "RI", first_name = "Mary")

test_that("search_npi() errors on invalid values of `limit`", {
  expect_error(search_npi(limit = -1))
  expect_error(search_npi(limit = 0))
  expect_error(search_npi(limit = 1201))
})

