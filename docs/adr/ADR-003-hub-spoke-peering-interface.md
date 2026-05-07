# ADR-003: Simplified hub-peering interface via hub_vnet_id / hub_vnet_name

**Status:** Accepted
**Date:** 2026-05-06
**Authors:** Platform Engineering (BDT-MSD)

## Context

Hub-and-spoke VNet peering requires two peering resources: spoke→hub and hub→spoke (reverse). The AVM module accepts a full `peerings` map with separate reverse-peering configuration. Exposing this directly to callers would require them to understand AVM's peering schema.

## Decision

Expose a simplified interface: `hub_vnet_id` (resource ID) and `hub_vnet_name` (name for peering naming). If both are non-empty, `locals.tf` constructs the full bidirectional AVM peering map automatically with BDT-MSD-standard settings:

- `allow_forwarded_traffic = true`
- `allow_virtual_network_access = true`
- `use_remote_gateways = true` (spoke uses hub gateway)
- `create_reverse_peering = true`
- `reverse_allow_gateway_transit = true`

## Rationale

- Callers only need two inputs to get a correctly configured hub peering — no need to understand AVM's `peerings` map schema.
- The module enforces BDT-MSD peering conventions (gateway transit, forwarded traffic) that would otherwise rely on callers getting the settings right.
- Peering names follow the BDT-MSD pattern: `peer-<spoke-vnet-name>-to-<hub-vnet-name>`.

## Consequences

- The simplified interface only supports a single hub peering. Multi-hub scenarios would require a future variable change and a MINOR version bump.
- Callers cannot override the peering settings (gateway transit, forwarded traffic) — this is intentional to enforce the standard. If customisation is needed, a MAJOR version bump would be required to expose the full `peerings` map.
- If `hub_vnet_id` is set but `hub_vnet_name` is empty (or vice versa), no peering is created. This is a silent no-op by design — validation was intentionally omitted to keep the interface simple.
