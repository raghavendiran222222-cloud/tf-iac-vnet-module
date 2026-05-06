# Changelog

All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning 2.0.0](https://semver.org/)

---

## [1.0.0] - 2026-05-06

### Added
- Initial release of `tf-iac-vnet-module`.
- Wraps Azure Verified Module `Azure/avm-res-network-virtualnetwork/azurerm` v0.17.1
  instead of raw `azurerm_virtual_network` resources, per FDD §2.3.5.
- BDT-MSD naming validation on `resource_group_name` and `vnet_name` (FDD §2.4.1).
- BDT-MSD required tag enforcement via `variable "tags"` validation (FDD Table 12).
- Automatic `CreationDate` tag injection via `locals.tf`.
- Simplified hub-and-spoke peering interface via `hub_vnet_id` / `hub_vnet_name`
  inputs; reverse peering created automatically (FDD §2.3.6).
- Optional resource lock via `enable_resource_lock` (recommended for prod).
- Optional diagnostic settings via `log_analytics_workspace_id`.
- `examples/basic` — spoke VNet with two subnets, no hub peering.
- `tests/test_vnet_module.py` — pytest/tftest coverage (6 tests).
- `.gitignore`, `README.MD`, `CHANGELOG.MD`.

### Version matrix (confirmed 2026-05-06)
| Component | Version |
|---|---|
| Terraform | >= 1.9.0, < 2.0.0 (latest: 1.15.1) |
| hashicorp/azurerm | ~> 4.71 (latest: 4.71.0) |
| Azure/azapi | ~> 2.9 (latest: 2.9.0) |
| AVM VNet module | 0.17.1 |
