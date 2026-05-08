# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/).

## [1.0.0] - 2026-05-08

### Added

- Initial release of `tf-iac-vnet-module`
- Azure Verified Module (AVM) wrapper: `Azure/avm-res-network-virtualnetwork/azurerm` v0.17.1
- Generic opinionated variable interface with tag and location validation
- Required tag enforcement: `Application`, `Owner`, `Environment`, `CostCenter`
- Auto-injected tags: `ManagedBy = "Terraform"`, `CreatedDate`
- Approved region validation: `eastus2`, `centralus`, `eastus`, `westus2`, `westeurope`, `northeurope`
- Flexible subnet interface supporting:
  - Service endpoints
  - NSG and Route Table associations
  - Service delegations
- Hub-spoke peering with automatic bidirectional configuration via `hub_vnet_id` / `hub_vnet_name`
- Optional `CanNotDelete` resource lock via `enable_resource_lock`
- Optional Log Analytics diagnostic settings via `log_analytics_workspace_id`
- Optional DDoS Protection Plan association via `ddos_protection_plan_id`
- Custom DNS server support via `dns_servers`
- `examples/basic` — 2-subnet spoke VNet with service endpoints, no peering
- 6 pytest/tftest plan-only tests
- `.gitignore` with standard Terraform exclusions

### Version Matrix

| Component                      | Version          |
|-------------------------------|-----------------|
| Terraform                      | `>= 1.9.0, < 2.0.0` |
| hashicorp/azurerm              | `~> 4.71`       |
| Azure/azapi                    | `~> 2.9`        |
| AVM VNet module                | `0.17.1`        |
| tftest (Python)                | `1.8.7`         |
