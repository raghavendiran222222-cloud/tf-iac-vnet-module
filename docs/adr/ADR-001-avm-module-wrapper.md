# ADR-001: Use Azure Verified Module as the underlying network resource

**Status:** Accepted
**Date:** 2026-05-06
**Authors:** Platform Engineering (BDT-MSD)

## Context

The module needs to deploy Azure Virtual Networks with subnets, peerings, resource locks, and diagnostic settings. Two implementation options were evaluated:

**Option A — Raw `azurerm` resources:** Call `azurerm_virtual_network`, `azurerm_subnet`, `azurerm_virtual_network_peering` directly, writing all the resource plumbing in this module.

**Option B — Azure Verified Module (AVM):** Wrap `Azure/avm-res-network-virtualnetwork/azurerm`, which is maintained by Microsoft and the AVM community. The tier-2 module adds only BDT-MSD enterprise conventions (naming, tags, region, peering interface) on top.

## Decision

Use **Option B — AVM wrapper**. This module is a Tier-2 pattern module that consumes the AVM Tier-1 resource module and enforces enterprise conventions.

## Rationale

- AVM handles the low-level resource complexity (lock sub-resources, diagnostic setting schema, peering bidirectionality) with tested, maintained code.
- The AVM module is owned by Microsoft and receives ongoing updates for API changes and provider version bumps.
- A Tier-2 wrapper is the correct place for BDT-MSD-specific opinions (naming regex, approved regions, required tags, `enable_telemetry = false`).
- Calling AVM directly from landing-zone code would make enforcing enterprise conventions impossible — this wrapper is the enforcement point.

## Consequences

- The module is tightly coupled to `Azure/avm-res-network-virtualnetwork/azurerm`. AVM breaking changes require a corresponding update here.
- AVM's variable schema changes must be absorbed at the wrapper boundary. The `avm_subnets`, `avm_peerings`, and `diagnostic_settings` locals in `locals.tf` perform this schema translation.
- The AVM version must be pinned explicitly and bumped via PR to maintain reproducibility.
