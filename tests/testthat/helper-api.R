# Keep API fixtures independent of DNS and avoid real pagination delays.
# Copies share a private environment so recursion uses the mocked functions too.
with_npi_mock_api <- function(code) {
  mock_env <- new.env(parent = parent.frame())
  functions <- c(
    "npi_search", "npi_process_results", "npi_control_requests",
    "npi_get_results", "npi_get", "npi_api"
  )
  for (name in functions) {
    fun <- get(name, envir = mock_env)
    environment(fun) <- mock_env
    assign(name, fun, envir = mock_env)
  }
  evalq({
    mockery::stub(npi_api, "curl::has_internet", TRUE)
    mockery::stub(npi_control_requests, "Sys.sleep", NULL)
  }, envir = mock_env)
  httptest::with_mock_api(eval(substitute(code), envir = mock_env))
}
