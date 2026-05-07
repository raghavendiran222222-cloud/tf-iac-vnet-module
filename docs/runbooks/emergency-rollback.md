# Runbook: Emergency module rollback

**Severity:** P2 — consumers are broken by a module regression.
**Owner:** Platform Engineering (BDT-MSD)

## When to use this runbook

Use when:
- A newly released module version (`vX.Y.Z`) causes `terraform plan` failures or unexpected resource changes in consumer stacks.
- A regression is confirmed and cannot be hotfixed quickly.

## Option A — Pin consumers to the previous version (immediate)

Consumers should already be pinned to an explicit version. Ask them to revert their module version pin:

```hcl
# In the consumer's Terraform code, revert the version to the last known-good tag:
module "spoke_vnet" {
  source  = "git::https://github.com/bdtmsd/tf-iac-vnet-module.git?ref=v1.2.3"
  # was: ref=v1.3.0 (broken)
}
```

This does not require any action in this repository. Consumers control their own pins.

## Option B — Retract the GitHub Release (visibility only)

GitHub does not support deleting a release tag after it has been used by consumers. You can mark the release as a pre-release or add a warning to the release notes, but this does not prevent consumption.

To retract (mark as draft + add warning):

```bash
gh release edit v1.3.0 --prerelease --notes "⚠️ RETRACTED — regression in subnet delegation. Pin to v1.2.3 until v1.3.1 is released."
```

## Option C — Hotfix release (preferred for quick fix)

1. Create a branch from the broken tag:
   ```bash
   git checkout -b hotfix/v1.3.1 v1.3.0
   ```

2. Apply the fix and commit with `fix:` prefix:
   ```bash
   git commit -m "fix(subnets): correct delegation schema transformation"
   ```

3. Push and open a PR against `main` (not the hotfix branch).
   - Branch protection requires a passing plan and CODEOWNERS approval.
   - release-please will pick up the `fix:` commit and create a patch release PR.

4. Once merged, release-please creates `v1.3.1` automatically.

5. Notify consumers to update their pins to `v1.3.1`.

## Communication template

```
Subject: [tf-iac-vnet-module] v1.3.0 regression — pin to v1.2.3

A regression was identified in v1.3.0 affecting [describe impact].

Immediate action: update your module source pin to ?ref=v1.2.3 and run terraform plan.

Root cause and fix are tracked in [link to issue].
A patch release v1.3.1 is expected by [date].

— Platform Engineering
```

## Severity escalation

If the broken module is causing production infrastructure failures (not just plan failures), escalate to P1 and follow your organisation's incident response process.
