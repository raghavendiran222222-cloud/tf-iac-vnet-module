# ADR-004: release-please for automated semantic versioning

**Status:** Accepted
**Date:** 2026-05-06
**Authors:** Platform Engineering (BDT-MSD)

## Context

Module releases require: bumping the version, updating CHANGELOG.MD, creating a Git tag, and publishing a GitHub Release. Options evaluated:

**Option A — Manual:** Engineer manually edits the version, writes changelog, creates a tag, and pushes a release. Error-prone and inconsistent.

**Option B — semantic-release:** Fully automated but opinionated about branch names, requires Node.js toolchain, and can be brittle in Terraform module repos.

**Option C — release-please (Google):** Reads conventional commits, creates a "Release PR" that bumps the version and updates CHANGELOG.MD. When the PR is merged, release-please creates the tag and GitHub Release automatically.

## Decision

Use **release-please** (`googleapis/release-please-action@v4`) with `release-type: terraform-module`.

## Rationale

- Release-please is maintained by Google and widely used in Terraform module repos.
- The "Release PR" pattern gives the team a human review step before any tag is created — the PR is the audit trail.
- Conventional commits (`feat:`, `fix:`, `chore:`, `feat!:`) drive the SemVer bump automatically.
- CHANGELOG.MD is auto-generated from commit messages, eliminating manual changelog maintenance.
- `bump-minor-pre-major: true` ensures `feat:` bumps minor (not patch) even before v1.0.0.

## Consequences

- All commit messages on `main` must follow the Conventional Commits spec. Non-conforming messages are ignored by release-please (they don't trigger a version bump).
- The `.release-please-manifest.json` file tracks the current version and must not be manually edited.
- The `release-please-config.json` must set `changelog-path: CHANGELOG.MD` to match the uppercase filename convention in this repo.
- A post-release job verifies that terraform-docs is up to date with `fail-on-diff: true`, catching any manual README edits that diverged from the module schema.
