# Package Setup -----------------------------------------------------------

library(devtools)
library(usethis)
library(desc)

# Remove default DESC
unlink("DESCRIPTION")

# Create and clean desc
my_desc <- description$new("!new")

# Set your package name
my_desc$set("Package", "npi")

# Set your name
my_desc$set("Authors@R", "person('Frank', 'Farach',
            email = 'frank.farach@gmail.com',
            role = c('cre', 'aut'))")

# Remove some author fields
my_desc$del("Maintainer")

# Set the version
my_desc$set_version("0.0.0.9000")

# The title of your package
my_desc$set(Title = "Access the U.S. National Provider Identifier
            Registry API")

# The description of your package
my_desc$set(Description = "Access the United States National Provider
            Identifier Registry API (if available) and provide informative
            error messages when it's not.")

# The urls
my_desc$set("URL", "https://github.com/frankfarach/npi")
my_desc$set("BugReports", "https://github.com/frankfarach/npi/issues")

# Dependencies
my_desc$set("Depends", "R (>= 2.10")
use_tidy_description()

# Save everyting
my_desc$write(file = "DESCRIPTION")

# If you want to use the MIT licence, code of conduct, and lifecycle badge
use_mit_license(name = "Frank Farach")
use_code_of_conduct()
use_lifecycle_badge("Experimental")
use_news_md()

# Get the dependencies
use_package("httr")
use_package("jsonlite")
use_package("curl")
use_package("attempt")
use_package("purrr")
use_package("stringr")
use_package("dplyr")

# Add testing, vignette, and README.Rmd
use_testthat()
use_readme_rmd()

# Set up continuous integration
use_travis()
use_coverage()
use_appveyor()

# Clean your description
use_tidy_description()
