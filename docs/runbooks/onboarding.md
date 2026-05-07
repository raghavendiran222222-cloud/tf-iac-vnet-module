# Runbook: New contributor onboarding

**Owner:** Platform Engineering (BDT-MSD)
**Goal:** Go from zero to a green local `terraform plan` in under 15 minutes.

## Prerequisites

- GitHub account added to the `bdtmsd` organisation and `platform-engineering` team.
- Azure subscription access (for running the speculative plan locally).
- `az login` completed with an account that has at least Reader on the target subscription.

## Step 1 — Clone and bootstrap (5 min)

```bash
gh repo clone bdtmsd/tf-iac-vnet-module
cd tf-iac-vnet-module
make bootstrap   # installs pre-commit hooks + terraform init
```

**Option A (container):** Open in VS Code → "Reopen in Container" (uses `.devcontainer/devcontainer.json`). All tools are pre-installed.

**Option B (local):** Install [mise](https://mise.jdx.dev/) and run:

```bash
mise install     # installs terraform 1.9.8 + python 3.13
pip install pre-commit pytest tftest
pre-commit install
```

## Step 2 — Read the docs (5 min)

1. `README.MD` — module interface (inputs, outputs, quick start).
2. `docs/adr/` — understand the five key decisions that shaped this module.
3. `CHANGELOG.MD` — what changed recently.

## Step 3 — Verify your environment

```bash
terraform version          # should show >= 1.9.8
make lint                  # pre-commit run --all-files (should be clean)
make validate              # terraform fmt + validate
```

## Step 4 — Run a local plan (optional, requires Azure access)

```bash
export ARM_SUBSCRIPTION_ID="<your-sub-id>"
make plan                  # creates override.tf, inits, plans examples/basic
```

## Step 5 — Open your first PR

1. Create a branch: `git checkout -b feat/your-feature`
2. Make changes, commit with conventional commit format: `feat(subnets): add delegation support`
3. Push and open a PR: `gh pr create`
4. The `PR Checks` workflow runs automatically. Review the plan comment.
5. Request review from `@bdtmsd/platform-engineering` (CODEOWNERS auto-assigns).

## Branch protection rules (for reference)

All PRs to `main` require:

- `TF Format & Validate` check passing
- `HCP Terraform Speculative Plan` check passing (if Azure vars configured)
- `TF-test` check passing (if Azure vars configured)
- At least 1 CODEOWNERS approval
- No force pushes

## Getting help

- Open an issue using the bug or feature templates.
- Slack: `#platform-engineering` (internal).
- For urgent module regressions, see `docs/runbooks/emergency-rollback.md`.
