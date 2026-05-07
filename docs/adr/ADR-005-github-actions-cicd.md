# ADR-005: GitHub Actions as the CI/CD platform

**Status:** Accepted
**Date:** 2026-05-06
**Authors:** Platform Engineering (BDT-MSD)

## Context

The module repository needs CI/CD for PR validation (static checks, speculative plan, tests) and release automation. Options evaluated:

**Option A — Azure DevOps Pipelines:** Strong Azure integration, supports workload identity federation service connections, but requires a separate ADO organization and adds cognitive overhead when the code already lives on GitHub.

**Option B — GitHub Actions:** Runs where the code lives. Native OIDC support with `azure/login@v2`. First-class Dependabot support for keeping Actions current. PR comments, SARIF upload, and GitHub Releases are all native features.

## Decision

Use **GitHub Actions** with three workflow files:

- `feature-checks.yml` — static checks on feature branches (no Azure auth)
- `pr-checks.yml` — full quality gate on PRs to main (OIDC auth, plan, tests)
- `release.yml` — automated release lifecycle via release-please

## Rationale

- The repository is hosted on GitHub; co-locating CI avoids round-trips to a separate CI platform.
- GitHub OIDC federation is first-class and well-documented.
- GitHub Environments can gate deployments with required reviewers — a future enhancement path.
- All Actions are pinned by commit SHA (not mutable tags) per ALZ §06 supply-chain security. Dependabot maintains the pins.
- `actionlint` and `zizmor` in pre-commit hooks validate workflow YAML before push.

## Consequences

- If the organisation moves to Azure DevOps, workflows must be rewritten in ADO YAML pipeline syntax.
- GitHub Actions usage counts against the organisation's minutes quota (free for public repos; billed for private repos).
- Self-hosted runners would be needed if network-isolated Azure resources are required in CI. Currently, GitHub-hosted runners with OIDC federation are sufficient.
- All Actions must be referenced by SHA, not tag. Dependabot is configured in `.github/dependabot.yml` to automate SHA updates.
