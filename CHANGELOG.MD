# Changelog

All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
Versioning: [Semantic Versioning 2.0.0](https://semver.org/)

---

## 0.1.0 (2026-05-07)


### Features

* add AVM vnet module wrapper with peering, lock, and diagnostics ([198cbb3](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/198cbb324f52fbeb7fe3f4c128c5dd34118f3183))
* add devcontainer, mise toolchain pinning, and issue templates ([1797894](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/17978948d78203e221290554aab076caa93c4ffc))
* add input variables with BDT-MSD naming and tag validations ([8117b03](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/8117b035bbe515df804f9c30b788dbf1630e9205))
* add locals for tag merging, peering guards, and AVM schema shaping ([07b6bb6](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/07b6bb619bbd2a2b7c46dffe109023d9c5bb966d))
* add module outputs for vnet id, subnets, peerings, and resource object ([9c64714](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/9c6471450d96b4b03ad81565642f81bee15d16ec))


### Bug Fixes

* align terraform version to 1.5.7 to match AVM vnet module constraint ([09d8674](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/09d8674955d84889433f14b3f6e4d9639077c11b))
* bump terraform version to 1.9.8 to satisfy AVM subnet module constraint ([6f2085f](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/6f2085fe538279513f67bd4c43bc918f80aa4c1a))
* declare examples/basic variables so tfvars and CI -var flags resolve correctly ([4ed08b2](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/4ed08b28de419aab94b40daa3648e634189199f6))
* remove deprecated empty azapi proxy provider block ([22703d9](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/22703d97683f0cc719a6406cdf3f2d53e1d20683))
* resolve all CI pipeline failures ([de31791](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/de31791b2ab25bd5bf0aa9135700637f35aecb4f))
* resolve CI failures in speculative plan and TF-test jobs ([f375726](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/f3757262b99bad1e6275a7c655f590beeff6c54e))
* skip speculative-plan and tftest when Azure secrets are not configured ([df8135f](https://github.com/raghavendiran222222-cloud/tf-iac-vnet-module/commit/df8135f2485e128b1398743b134e190fe72408e6))

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
| --- | --- |
| Terraform | >= 1.9.0, < 2.0.0 (latest: 1.15.1) |
| hashicorp/azurerm | ~> 4.71 (latest: 4.71.0) |
| Azure/azapi | ~> 2.9 (latest: 2.9.0) |
| AVM VNet module | 0.17.1 |
