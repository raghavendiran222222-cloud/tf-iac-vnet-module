# tf-iac-vnet-module

Opinionated BDT-MSD Tier-2 wrapper around the **Azure Verified Module** for Virtual Networks
([`Azure/avm-res-network-virtualnetwork/azurerm` v0.17.1](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest)).

Enforces BDT-MSD naming conventions (FDD §2.4), required tags (FDD Table 12),
hub-and-spoke peering patterns (FDD §2.3.6), and approved Azure regions (FDD §1.3 A2).

## Quick start

```hcl
module "spoke_vnet" {
  source = "git::https://github.com/bdtmsd/tf-iac-vnet-module.git?ref=v1.0.0"

  subscription_id     = var.subscription_id
  resource_group_name = "rg-bdt-myapp-prod-eus2-001"
  location            = "eastus2"
  vnet_name           = "vnet-myapp-prod-eus2-001"
  address_space       = ["10.20.0.0/16"]

  subnets = {
    "snet-app-prod-eus2-001" = { address_prefix = "10.20.1.0/24" }
  }

  enable_resource_lock = true

  tags = {
    Application         = "MyApp"
    DevOwner            = "dev@bdtmsd.com"
    BusinessOwner       = "owner@bdtmsd.com"
    Environment         = "prod"
    DataClassification  = "Restricted"
    BusinessCriticality = "High"
    IACRepository       = "https://github.com/bdtmsd/tf-iac-vnet-module"
  }
}
```

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0, < 2.0.0 |
| hashicorp/azurerm | ~> 4.71 |
| Azure/azapi | ~> 2.9 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| subscription\_id | Azure Subscription ID where the VNet will be deployed. Used to construct the resource group parent\_id for the AVM module. | `string` | n/a | yes |
| resource\_group\_name | Name of the existing Resource Group. Pattern: rg-\<deptName\>-\<workload\>-\<env\>-\<region\>-\<instance\>. | `string` | n/a | yes |
| vnet\_name | Name of the Virtual Network. Pattern: vnet-\<workload\>-\<env\>-\<region\>-\<instance\>. | `string` | n/a | yes |
| address\_space | One or more CIDR address spaces for the Virtual Network. | `list(string)` | n/a | yes |
| tags | Required BDT-MSD tags (FDD Table 12). Must include: Application, DevOwner, BusinessOwner, Environment, DataClassification, BusinessCriticality, IACRepository. CreationDate is injected automatically by locals.tf. | `map(string)` | n/a | yes |
| location | Azure region. BDT-MSD approved regions per assumption A2 (FDD §1.3). | `string` | `"eastus2"` | no |
| subnets | Map of subnet objects. Key = subnet name (pattern: snet-\<workload\>-\<env\>-\<region\>-\<instance\>). | `map(object({...}))` | `{}` | no |
| hub\_vnet\_id | Resource ID of the hub VNet to peer with. Leave empty to skip peering. | `string` | `""` | no |
| hub\_vnet\_name | Name of the hub VNet. Required when hub\_vnet\_id is set. | `string` | `""` | no |
| enable\_resource\_lock | Whether to apply a CanNotDelete lock to the VNet. Recommended for prod environments. | `bool` | `false` | no |
| log\_analytics\_workspace\_id | Resource ID of the Log Analytics workspace for diagnostic settings. Leave empty to skip. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet\_id | Resource ID of the Virtual Network. |
| vnet\_name | Name of the Virtual Network. |
| vnet\_address\_spaces | Address spaces of the Virtual Network. |
| subnet\_ids | Map of subnet name to subnet resource ID. |
| subnet\_address\_prefixes | Map of subnet name to address prefix. |
| peerings | VNet peering information from the AVM module. |
| resource | Full AVM VNet resource object. Use for advanced attribute access. |
<!-- END_TF_DOCS -->

---

## Documentation

| Path | Description |
|------|-------------|
| `docs/adr/` | Architecture Decision Records — five key design decisions |
| `docs/runbooks/credential-leak.md` | P1 response: CI credential exposure |
| `docs/runbooks/emergency-rollback.md` | P2 response: rolling back a broken module release |
| `docs/runbooks/onboarding.md` | New contributor setup guide |
| `examples/basic/` | Basic spoke VNet with two subnets |
| `tests/` | pytest / tftest plan-based tests |

---

## Maintained by

| Name | Role |
|------|------|
| Raghavendiran N | Senior DevOps Engineer |
| Sakthivel Manohar | Senior DevOps Engineer |
