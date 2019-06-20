context("test-api.R")

# Global variables for GET request
API_VERSION <- "2.1"
BASE_URL <- "https://npiregistry.cms.hhs.gov/api/"
USER_AGENT <- "http://github.com/frankfarach/npi"


test_that("npi_config() sets default user_agent correctly", {
  expect_identical(npi_config(), httr::config(useragent = USER_AGENT))
})

test_that("npi_config() uses customized user agent option if defined", {
  options(npi_user_agent = "foo")
  expect_identical(npi_config(), httr::config(useragent = "foo"))
  options(npi_user_agent = USER_AGENT)
})

# with_mock_api({
#   test_that("Requests happen and have the correct URL and user agent", {
#     npi <- "1437187390"
#     req <- get_url(query = list(number = npi), url = BASE_URL,
#                    ua = USER_AGENT, sleep = 0L)
#     expect_is(req, "response")
#     expect_identical(req$url, paste0(BASE_URL, "&number=", npi))
#     expect_identical(req$request$options$useragent, USER_AGENT)
#   })
# })



test_that("We throw a custom error when the API returns a bad status code", {
  status <- 400L
  url <- "foo"
  stub(npi_handle_response, "httr::status_code", status)
  resp <- structure(list(url = url), class = "response")

  expect_error(
    npi_handle_response(resp),
    class = "request_failed_error")
})


# with_mock_api({
#   test_that("Response validation catches logic errors returned by API", {
#     req <- search_registry()
#     expect_error(npi_handle_response(unclass(req)), class = "error_bad_argument")
#     expect_error(npi_handle_response(req), class = "request_logic_error")
#   })
# })


test_that("nppes_api() throws an error for non-list query arguments", {
  expect_error(nppes_api(query = "foo", url = BASE_URL,
                         ua = USER_AGENT, sleep = 0L),
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
  expect_error(search_npi(limit = -1), lim)
  expect_error(search_npi(limit = 0), lim)
  expect_error(search_npi(limit = 1201), lim)

  # Sleep
  expect_error(search_npi(sleep = -1), class = "error_bad_argument")
})


with_mock_api({
  test_that("We can catch request logic errors in the API response", {
    expect_error(search_npi(provider_type = 1), class = "request_logic_error")
  })
})


with_mock_api({
  test_that("A valid search_npi() call meets structural expectations", {
    res <- search_npi(city = "Atlanta")
    expected_types <- c("integer", "character", rep("list", 7), rep("double", 2))
    names(expected_types) <- c("npi", "provider_type", "basic", "other_names",
                        "identifiers", "taxonomies", "addresses", "practice_locations",
                        "endpoints", "created_date", "last_updated_date")

    expect_is(res, c("npi_results", "tbl_df", "tbl", "data.frame"))
    expect_identical(purrr::map_chr(res, typeof), expected_types)
    expect_equal(nrow(res), 10)
  })
})


test_that("get_results() catches improperly structured responses", {
  good_resp <- structure(list(), class = "nppes_api")
  bad_resp <- unclass(good_resp)
  resps <- list(good_resp, bad_resp)
  not_a_list <- "foo"

  expect_error(get_results(not_a_list), class = "error_bad_argument")
  expect_error(get_results(resps), class = "bad_class_error")
})


with_mock_api({
  test_that("summary.npi_results() method works as expected", {
    atl <- search_npi(city = "Atlanta")
    expect_types <- c("integer", rep("character", 5))
    expect_names <- c("npi", "name", "provider_type",
                      "primary_practice_address", "phone",
                      "primary_taxonomy")

    checkmate::expect_tibble(summary(atl), types = expect_types)
    expect_identical(names(summary(atl)), expect_names)
  })
})
