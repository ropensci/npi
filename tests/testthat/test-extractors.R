context("test-extractors.R")

test_that("new_npi_results() correctly handles inputs", {
  expect_error(new_npi_results(data.frame(a = 1)))
})

test_that("new_npi_results() correctly constructs S3 class", {
  tbl <- tibble::tibble(a = 1L)
  cls <- c("npi_results", "tbl_df", "tbl", "data.frame")
  tbl_class <- structure(.Data = tbl, class = cls)

  expect_identical(new_npi_results(tbl), tbl_class)
})

test_that("validate_npi_results() catches invalid inputs", {
  data(npis)
  res_bad_ncol <- res_bad_name <- res_bad_class <- npis
  res_bad_ncol <- res_bad_ncol[, -11]
  names(res_bad_name)[3] <- "basic2"
  class(res_bad_class) <- c("tbl_df", "tbl", "data.frame")

  expect_error(validate_npi_results(res_bad_ncol))
  expect_error(validate_npi_results(res_bad_name),
    class = "bad_names_error"
  )
})


# Set up global objects for testing
df <- tibble(
  key = letters[1:2],
  lc1 = list(1, 1:2),
  lc2 = list(LETTERS[1], LETTERS[1:5])
)

lc1_df <- tribble(
  ~key, ~lc1,
  "a", 1,
  "b", 1,
  "b", 2
)

lc2_df <- tribble(
  ~key, ~lc2,
  "a", "A",
  "b", "A",
  "b", "B",
  "b", "C",
  "b", "D",
  "b", "E"
)


test_that("list_to_tibble() throws an error for bad arguments", {
  expect_error(list_to_tibble("foo", "bar", depth = 3L))
})


test_that("get_list_col() works as expected", {
  expect_error(get_list_col("foo", lc1, "key"), class = "error_bad_argument")
  expect_identical(get_list_col(df, "lc1", "key"), lc1_df)
  expect_identical(get_list_col(df, "lc2", "key"), lc2_df)
})


test_that("clean_credentials works as expected", {
  expect_error(clean_credentials(1L), "x must be a character vector")
  expect_equal(
    clean_credentials(c("M.D.", "Ph.D.", "MD, Ph.D.")),
    list("MD", "PhD", c("MD", "PhD"))
  )
})


test_that("address extractor works", {
  address <- tribble(
    ~"address_1", ~"address_2", ~"city", ~"state", ~"postal_code",
    "115 WEST 27TH STREET", "4TH FLOOR", "NEW YORK CITY", "NY", "100016217"
  )

  expect_equal(
    make_full_address(
      address, "address_1", "address_2", "city", "state", "postal_code"
    ),
    "115 WEST 27TH STREET 4TH FLOOR, NEW YORK CITY, NY 100016217"
  )
})
