# ADR-002: OIDC federated credentials for CI/CD authentication

**Status:** Accepted
**Date:** 2026-05-06
**Authors:** Platform Engineering (BDT-MSD)

## Context

The CI/CD pipeline (GitHub Actions) needs to authenticate to Azure to run `terraform plan` and validate the module against real infrastructure. Three options were evaluated:

**Option A — Service principal client secret stored in GitHub Secrets:** Long-lived credential, exfiltration risk via workflow YAML edits, rotation burden.

**Option B — OIDC federation with `azure/login@v2` + `ARM_USE_CLI=true`:** No stored secret. GitHub runner requests a short-lived OIDC JWT, exchanges it for a 1-hour Azure access token via the Entra federated credential. Authentication uses `az login` which the azurerm provider picks up automatically via `ARM_USE_CLI=true`.

**Option C — OIDC with `ARM_USE_OIDC=true`:** The azurerm provider requests the OIDC token directly. Simpler setup but requires `ARM_OIDC_TOKEN` to be passed explicitly in some scenarios.

## Decision

Use **Option B — `azure/login@v2` + `ARM_USE_CLI=true`**.

## Rationale

- Eliminates the entire class of "leaked client secret" incidents.
- `azure/login@v2` is the canonical Microsoft-maintained Action for OIDC to Azure.
- `ARM_USE_CLI=true` + a successful `az login` session is the most reliable auth path for the azurerm provider in CI.
- Client IDs, tenant IDs, and subscription IDs are not sensitive and are stored as GitHub **Variables** (not Secrets), reducing secret sprawl.
- Federated credential subjects are scoped to `repo:bdtmsd/tf-iac-vnet-module:pull_request` — the minimum scope for PR jobs.

## Consequences

- A one-time Azure setup step is required: create a service principal, add a federated credential with the correct subject, and assign Contributor RBAC on the target subscription.
- The federated credential subject must match the GitHub Actions context exactly. A mismatch silently fails authentication.
- `ARM_CLIENT_SECRET` must never be created or stored anywhere in this repository.
- If the SPN is ever compromised, rotating the federated credential (not a password) is sufficient.
