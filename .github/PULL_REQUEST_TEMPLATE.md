## What
<!-- Describe what this PR changes -->

## Why
<!-- Describe why this change is needed -->

## How (high-level)
<!-- Brief explanation of the approach taken -->

## Affected module surface
- [ ] `variables.tf` — new or changed inputs
- [ ] `outputs.tf` — new or changed outputs
- [ ] `locals.tf` — logic changes
- [ ] `main.tf` — module call changes
- [ ] `examples/` — example updated
- [ ] `tests/` — tests updated

## Checklist
- [ ] `terraform fmt -recursive .` passes locally
- [ ] `terraform validate` passes locally
- [ ] CI plan reviewed in PR comment
- [ ] If inputs/outputs changed — README regenerated via `make docs`
- [ ] If breaking change — MAJOR version bump noted in CHANGELOG.MD
- [ ] If breaking change — migration notes included in PR description
