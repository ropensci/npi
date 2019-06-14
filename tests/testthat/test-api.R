context("test-api.R")

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
  expect_error(get_url(list(), url = TRUE, ua = USER_AGENT, sleep = 0),
               class = "error_bad_argument")
  expect_error(get_url(list(), url = BASE_URL, ua = TRUE, sleep = 0),
               class = "error_bad_argument")
})


with_mock_api({
  test_that("Response validation catches logic errors returned by API", {
    req <- get_url(query = list(provider_type = 1), url = BASE_URL,
                   ua = USER_AGENT, sleep = 0L)
    expect_error(validate_response(unclass(req)),
                 "`resp` class must be `response`, not list.")
    expect_error(validate_response(req), class = "request_logic_error")
  })
})


test_that("nppes_api() throws an error for non-list query arguments", {
  expect_error(nppes_api(query = "foo", url = BASE_URL,
                         ua = USER_AGENT, sleep = 0),
               class = "error_bad_argument")
})


with_mock_api({
  test_that("nppes_api() returns an object with class `nppes_api` with functioning S3 print method", {
    req <- nppes_api(
      query = list(provider_type = 1, city = "Atlanta", limit = 2),
      url = BASE_URL, ua = USER_AGENT, sleep = 0L
    )
    expect_is(req, "nppes_api")
    capture_output(expect_invisible(print(req)))
  })
})


test_that("search_npi() messages when argument values are invalid", {
  # Provider type
  pt <- "provider_type must be one of: NULL, 1, or 2"
  expect_error(search_npi(provider_type = "NPI1"), pt)
  expect_error(search_npi(provider_type = 3), pt)

  # Use first name alias
  ufna <- "`use_first_name_alias` must be TRUE or FALSE if specified."
  expect_error(search_npi(use_first_name_alias = "foo"), ufna)

  # Address purpose
  expect_error(search_npi(address_purpose = "foo"))

  # Limit
  lim <- "`limit` must be a number between 1 and 1200"
  my_search <- purrr::partial(search_npi, state = "RI", first_name = "Mary")
  expect_error(search_npi(limit = -1), lim)
  expect_error(search_npi(limit = 0), lim)
  expect_error(search_npi(limit = 1201), lim)
})




# test_that("search_npi() passes the correct value of use_first_name_alias", {
#   res <- search_npi(use_first_name_alias = TRUE)
#   expect_equal())
#
# })
