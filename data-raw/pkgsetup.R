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
            role = c('cre', 'aut', 'cph'))")

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
my_desc$set("URL", "https://github.com/ropensci/npi")
my_desc$set("BugReports", "https://github.com/ropensci/npi/issues")

# Dependencies
my_desc$set("Depends", "R (>= 2.10")
use_tidy_description()

# Save everyting
my_desc$write(file = "DESCRIPTION")

# If you want to use the MIT licence, code of conduct, and lifecycle badge
use_mit_license(name = "Frank Farach")
use_code_of_conduct()
use_lifecycle_badge("Maturing")
use_news_md()

# Get the dependencies
use_package("httr")
use_package("jsonlite")
use_package("curl")
use_package("attempt")
use_package("purrr")
use_package("stringr")
use_package("dplyr")
use_package("tibble")
use_package("tidyr")
use_pipe()
document()

# Add testing, vignette, and README.Rmd
use_testthat()
use_readme_rmd()

# Set up continuous integration
use_travis()
use_coverage()
use_appveyor()

# Clean your description
use_tidy_description()

# Retrieve simple data set for demos
npis <- npi_search(city = "New York", state = "NY")

# Make data available to package users ----------------------------

usethis::use_data(npis, overwrite = TRUE)


# Hex Sticker! ------------------------------------------------------------

library(hexSticker)

img <- "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Caduceus_large.png/170px-Caduceus_large.png"

sticker(img, package = "npi", p_size = 8, s_x = 1, s_y = .75, s_width = .6, s_height = .7, filename = "inst/figure/npi.png")
