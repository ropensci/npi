# Contributing to npi

<!-- This CONTRIBUTING.md is adapted from https://gist.github.com/peterdesmet/e90a1b0dc17af6c12daf6e8b2f044e7c -->

Thanks for considering contributing to npi! It's people like you that make it rewarding to create, maintain, and improve this package.

npi is an open source project created and maintained by [Frank Farach](https://www.frankfarach.com/about) in his spare time. 

[repo]: https://github.com/frankfarach/npi
[issues]: https://github.com/frankfarach/npi/issues
[new_issue]: https://github.com/frankfarach/npi/issues/new
[website]: https://frankfarach.github.io/npi

## Code of conduct

This project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## How you can contribute

There are several ways you can contribute to this project, any of which is greatly appreciated. If you want to know more about why and how to contribute to open source projects like this one, see this [Open Source Guide](https://opensource.guide/how-to-contribute/).

### Share the love

Think npi is useful? Let others discover it, by telling them in person, via Twitter or a blog post.

### Ask a question

Using npi and got stuck? Browse the [documentation][website] and [issues][issues] to see if you can find a solution. Still stuck? Post your question as an [issue on GitHub][new_issue]. I'll do my best to address it, as questions often lead to better documentation or the discovery of bugs.

### Propose an idea

Have an idea for a new npi feature? Take a look at the [issue list][issues] to see if it isn't included or suggested yet. If not, suggest your idea as an [issue on GitHub][new_issue]. While I can't promise to implement your idea, it helps to:

* Explain in detail how it would work.
* Keep the scope as narrow as possible.

See below if you want to contribute code for your idea.

You're also welcome to join any discussion on an existing issue.

### Report a bug

Using npi and think you've discovered a bug? That's annoying! Don't let others have the same experience and report it as an [issue on GitHub][new_issue] so I can fix it. A good bug report makes it easier for me to do so in the limited time I have to work on this project, so kindly include the following in your report:

* Your operating system name and version (e.g. Mac OS 10.13.6)
* Any details about your local setup that might be helpful in troubleshooting, such as the output from running `sessionInfo()` from the R console
* Detailed steps to reproduce the bug, preferably in the form of a [minimum reproducible example](https://robjhyndman.com/hyndsight/minimal-reproducible-examples/)

### Improve the documentation

Noticed a typo? Think a function could use a better example? Good documentation makes all the difference, so your help to improve it is very welcome!

#### Function documentation

Functions are described as comments near their code and translated to documentation using [`roxygen2`](https://klutometis.github.io/roxygen/). If you want to improve a function description:

1. Go to `R/` directory in the [code repository][repo].
2. Look for the file with the name of the function.
3. [Propose a file change](https://help.github.com/articles/editing-files-in-another-user-s-repository/) to update the function documentation in the roxygen comments (starting with `#'`).

### Contribute code

Care to fix bugs or implement new functionality for npi? Awesome! 👏 Have a look at the [issue list][issues] and leave a comment on the things you want to work on. See also the development guidelines below.

## Development guidelines

Please follow [GitHub flow](https://guides.github.com/introduction/flow/) for development.

1. Fork [this repo][repo] and clone it to your computer. To learn more about this process, see [this guide](https://guides.github.com/activities/forking/).
2. If you have forked and cloned the project before and it has been a while since you worked on it, [pull changes from the original repo](https://help.github.com/articles/merging-an-upstream-repository-into-your-fork/) to your clone by using `git pull upstream master`.
3. Open the RStudio project file (`.Rproj`).
4. Make your changes:
    * Write your code.
    * Test your code (bonus points for adding unit tests).
    * Document your code (see function documentation above).
    * Check your code with `devtools::check()` and aim for 0 errors and warnings.
5. Commit and push your changes.
6. Submit a [pull request](https://guides.github.com/activities/forking/#making-a-pull-request).

Additionally:

* npi follows the [tidyverse](https://tidyverse.org/) style as detailed in the [tidyverse style guide](https://style.tidyverse.org/). Please lint your code with `lintr::lint_file()` prior to committing.
* npi uses roxygen2 for documentation. Before running devtools::document(), ensure you've update roxygen2 to the latest version and have used `@noRd` for functions that should not be exported.
* npi uses the [jsonlite](https://github.com/jeroen/jsonlite) package for wrangling JSON.
