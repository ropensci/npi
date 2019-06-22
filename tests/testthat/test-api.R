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


test_that("We throw a custom error when the API returns a bad status code", {
  status <- 400L
  url <- "foo"
  stub(npi_handle_response, "httr::status_code", status)
  resp <- structure(list(url = url), class = "response")

  expect_error(
    npi_handle_response(resp),
    class = "request_failed_error")
})


test_that("We throw a custom error when the API doesn't return JSON.", {
  status <- 200L
  http_type <- "application/xml"
  url <- "foo"
  stub(npi_handle_response, "httr::status_code", status)
  stub(npi_handle_response, "httr::http_type", http_type)
  resp <- structure(list(url = url,
                         headers = list(
                           `Content-Type` = http_type
                         )),
                    class = "response")

  expect_error(
    npi_handle_response(resp),
    class = "http_type_error")
})


with_mock_api({
  test_that("Response validation catches logic errors returned by API", {
    expect_error(npi_search(), class = "request_logic_error")
  })
})


test_that("npi_search() messages when argument values are invalid", {
  # Provider type
  pt <- "`enumeration_type` must be one of: NULL, 'ind', or 'org'."
  expect_error(npi_search(enumeration_type = "NPI1"), pt)
  expect_error(npi_search(enumeration_type = 3), pt)

  # Use first name alias
  ufna <- "`use_first_name_alias` must be TRUE or FALSE if specified."
  expect_error(npi_search(use_first_name_alias = "foo"), ufna)

  # Address purpose
  expect_error(npi_search(address_purpose = "foo"))

  # Limit
  lim <- "`limit` must be a number between 1 and 1200"
  expect_error(npi_search(limit = -1), lim)
  expect_error(npi_search(limit = 0), lim)
  expect_error(npi_search(limit = 1201), lim)
})


with_mock_api({
  test_that("We can catch request logic errors in the API response", {
    expect_error(npi_search(enumeration_type = "ind"), class = "request_logic_error")
  })
})


with_mock_api({
  test_that("A valid npi_search() call meets structural expectations", {
    res <- npi_search(city = "Atlanta")
    expected_types <- c("integer", "character", rep("list", 7), rep("double", 2))
    names(expected_types) <- c("npi", "enumeration_type", "basic", "other_names",
                        "identifiers", "taxonomies", "addresses", "practice_locations",
                        "endpoints", "created_date", "last_updated_date")

    expect_is(res, c("npi_results", "tbl_df", "tbl", "data.frame"))
    expect_identical(purrr::map_chr(res, typeof), expected_types)
    expect_equal(nrow(res), 10)
  })
})


with_mock_api({
  test_that("npi_summarizenpi_results() method works as expected", {
    atl <- npi_search(city = "Atlanta")
    expect_types <- c("integer", rep("character", 5))
    expect_names <- c("npi", "name", "enumeration_type",
                      "primary_practice_address", "phone",
                      "primary_taxonomy")

    checkmate::expect_tibble(npi_summarize(atl), types = expect_types)
    expect_identical(names(npi_summarize(atl)), expect_names)
  })
})


with_mock_api({
  test_that("enumeration_type controls values of enumeration_type in response", {
    atl_ind <- npi_search(city = "Atlanta", enumeration_type = "ind")
    atl_org <- npi_search(city = "Atlanta", enumeration_type = "org")

    expect_equal(all(atl_ind$enumeration_type == "Individual"), TRUE)
    expect_equal(all(atl_org$enumeration_type == "Organization"), TRUE)
  })
})


with_mock_api({
  test_that("npi_search() returns a npi", {
    res <- npi_search(enumeration_type = "ind",
                      first_name = "Bob",
                      use_first_name_alias = TRUE)

    expect_is(res, "npi_results")
  })
})


with_mock_api({
  test_that("Multiple requests happen as needed", {
    res <- npi_search(city = "Atlanta", limit = 201)
    expect_message(npi_search(city = "Atlanta", limit = 201),
                  "Retrieving more records...")
    expect_identical(dim(res), c(3L, 11L)) # Recorded responses manually edited
  })
})


with_mock_api({
  test_that("If we search for an existing NPI, we get back the correct one", {
    npi <- 1568946812
    res <- npi_search(number = npi)
    expect_equal(npi, res$npi)
  })
})


test_that("validate_npi_results throws a `bad_class_error` appropriately", {
  npi <- 1568946812
  res <- npi_search(number = npi)
  class(res) <- c("tbl_df", "tbl", "data.frame")  # Tibble class
  expect_error(validate_npi_results(res), class = "bad_class_error")
})
