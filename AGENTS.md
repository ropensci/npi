# Maintenance instructions for npi

These instructions apply to automated and agent-assisted maintenance of
this repository.

## Scope and review boundary

- Work only on this `npi` repository.
- Use one pull request per root cause. Do not combine unrelated bugs,
  dependency changes, or feature ideas.
- Never merge code, publish a release, submit to CRAN, close an issue,
  or post a public issue or pull-request comment without explicit
  maintainer approval.
- Search existing issues and pull requests before opening new work.

## Package maintenance

- Keep ordinary tests independent of the live NPI API. Use fixtures and
  mocks for deterministic tests.
- Add a regression test before fixing a confirmed bug whenever
  practical.
- Keep live API checks separate from package tests and assert only
  stable response structure.
- Test R-devel, current R, and the previous R release. Older R versions
  may continue to work, but are not actively tested.
- Do not raise `Depends: R` unless a reviewed change actually requires
  it.
- Preserve the package’s public behavior unless the issue or pull
  request explicitly justifies a change.

## Required validation

Run focused tests for changed behavior, then the full test suite and a
full `R CMD check`. For release-facing work, run `R CMD check --as-cran`
and record warnings and notes in `cran-comments.md`. Treat errors and
new warnings as blocking. Explain unavoidable local-environment notes
rather than changing package code for them.

## Priorities

Prioritize user-facing breakage, CRAN or CI failures, documentation
defects, and feature ideas in that order. When a report lacks enough
information, prepare a draft request for the maintainer instead of
guessing publicly.
