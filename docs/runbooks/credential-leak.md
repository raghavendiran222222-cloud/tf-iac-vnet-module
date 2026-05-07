# Runbook: Credential leak response

**Severity:** P1 — act immediately.
**Owner:** Platform Engineering (BDT-MSD)

## When to use this runbook

Use when:
- A GitHub Secret or Azure credential is suspected to be exposed (committed to Git, visible in CI logs, leaked via a third-party tool).
- A Gitleaks or GitHub secret-scanning alert fires.
- A suspicious sign-in appears in Entra ID logs for the CI service principal.

## Response steps

### 1. Revoke the credential immediately (< 5 minutes)

This module uses OIDC federation — there is no long-lived client secret. If the `ARM_CLIENT_ID` variable was exposed:

- The client ID itself is **not sensitive** (it's a public identifier, not a secret).
- If a `GITHUB_TOKEN` was leaked: GitHub tokens expire after the job completes. Check if it was a PAT; if so, revoke it at github.com → Settings → Developer settings → Personal access tokens.
- If a service principal was somehow given a client secret (violating ADR-002): revoke the secret immediately in Entra ID → App registrations → Certificates & secrets.

### 2. Rotate affected resources

If the federated credential subject was widened (e.g. `repo:org/repo:*` instead of `repo:org/repo:pull_request`):

```bash
# Narrow the federated credential subject back to pull_request scope
az ad app federated-credential update \
  --id <APP_ID> \
  --federated-credential-id <FIC_ID> \
  --parameters '{"subject": "repo:bdtmsd/tf-iac-vnet-module:pull_request"}'
```

### 3. Audit Entra sign-in logs

```bash
# Pull sign-ins for the CI service principal in the last 24h
az monitor activity-log list \
  --filter "eventTimestamp ge $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ) and resourceProvider eq 'Microsoft.Authorization'" \
  --query "[?caller == '<SPN_APP_ID>']" \
  --output table
```

Also check Entra ID → Monitoring → Sign-in logs → Filter by Application = `sp-alz-vnet-ci`.

Look for:
- Sign-ins outside GitHub's IP ranges (published at [GitHub meta API](https://api.github.com/meta)).
- Sign-ins with subject claims that don't match `pull_request`.
- Any new role assignments made by the SPN.

### 4. Re-deploy from a known-good SHA

If resources were modified outside of Git:

```bash
git log --oneline -10   # identify the last known-good commit
# Open a PR reverting any malicious changes, or re-apply the known-good plan via CI
```

### 5. Purge Git history if a secret was committed

```bash
# Install git-filter-repo (preferred over BFG)
pip install git-filter-repo

# Remove the file containing the secret from all history
git filter-repo --path path/to/secret-file --invert-paths

# Force-push (coordinate with the team — this rewrites history)
git push origin --force --all
```

> After force-push, all contributors must `git fetch --all` and reset their local branches.
> GitHub Support can also purge cached views of the file.

### 6. Postmortem

Open an issue within 48h with:
- Timeline of events.
- Root cause.
- Preventive measures taken.
- Any process or tooling changes.

## Prevention checklist

- [ ] `gitleaks` pre-commit hook installed (`pre-commit install`).
- [ ] GitHub secret scanning + push protection enabled on the repo.
- [ ] Federated credential subject is `repo:bdtmsd/tf-iac-vnet-module:pull_request` (not `*`).
- [ ] No `ARM_CLIENT_SECRET` created on the SPN ever.
- [ ] CODEOWNERS review required for workflow changes (an attacker modifying `pr-checks.yml` could exfiltrate `ARM_CLIENT_ID`).
