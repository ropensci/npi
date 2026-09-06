# npi maintenance

This repository uses a human-guided maintenance loop. Automated checks
establish facts; Codex may investigate and prepare tested pull requests;
Frank approves public decisions.

## Operating policy

- The weekly review runs after the scheduled package and API checks.
- Routine action updates are grouped monthly and limited to one open
  dependency-update pull request.
- Assistant-authored maintenance work is limited to two open pull
  requests at a time.
- Pull requests are grouped by root cause and opened ready for review
  only after local validation passes.
- Public replies are prepared as drafts for Frank. Automation does not
  merge, release, submit to CRAN, close issues, or publish comments.

## Supported environments

The active compatibility target is R-devel, the current R release, and
the previous R release. Older R versions may continue to work but are
not actively tested. The declared minimum R version is changed only when
a reviewed package change requires it.

## Weekly review

The review inspects new and updated issues, open pull requests, CI
results, the live NPI API smoke test, CRAN status, and recent releases.
It searches for existing work before opening anything and stays quiet
when there is no actionable change.

Confirmed defects receive a regression test, the smallest safe fix,
documentation updates when behavior changes, and a pull request
containing the cause, impact, before/after behavior, and validation
evidence. Incomplete reports receive a draft response. Feature requests
receive an impact and compatibility assessment and wait for maintainer
direction.

## Release checklist

When meaningful fixes accumulate, CRAN reports a problem, or an upstream
API change requires an update:

1.  Choose patch or minor version according to public behavior changes.
2.  Update `DESCRIPTION`, `NEWS.md`, generated documentation, citation
    metadata, `codemeta.json`, and `cran-comments.md`.
3.  Run focused tests, the full test suite, `R CMD build`, and
    `R CMD check --as-cran`.
4.  Record GitHub matrix, reverse-dependency, and external platform
    results when available.
5.  Open a release pull request for maintainer review.

CRAN submission, acceptance-email handling, tagging, GitHub release
creation, and publication verification remain explicit human-approved
steps. After acceptance, verify the canonical CRAN page, current-version
checks, GitHub release, and rOpenSci documentation.
