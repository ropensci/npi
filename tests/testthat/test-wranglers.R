context("test-wranglers.R")

# Test data
bad_npis_good_class <-
  bad_npis <- tibble::tibble(npis, extra_col = NA)
class(bad_npis_good_class) <-
  c("npi_results", "tbl_df", "tbl", "data.frame")
flat_npis_tax_colnames <-
  c(
    "npi",
    "taxonomies_code",
    "taxonomies_desc",
    "taxonomies_primary",
    "taxonomies_state",
    "taxonomies_license",
    "taxonomies_taxonomy_group"
  )
flat_npis_tax <- npi_flatten(npis, cols = "taxonomies")
flat_npis_tax_enumtype <- npi_flatten(npis, cols = "taxonomies", key = "enumeration_type")

# Tests for npi_flatten()
test_that("npi_flatten() rejects bad df argument", {
  expect_error(npi_flatten(bad_npis), class = "error_bad_argument")
  expect_error(npi_flatten(bad_npis_good_class))
})

test_that("npi_flatten() correctly handles non-null cols argument", {
  expect_identical(colnames(flat_npis_tax), flat_npis_tax_colnames)
})

test_that("npi_flatten() correctly handles user-specified value for key argument", {
  expect_identical(names(flat_npis_tax_enumtype)[1], "enumeration_type")
  expect_identical(names(flat_npis_tax_enumtype)[-1], names(flat_npis_tax)[-1])
})
