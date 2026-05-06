# tf-iac-vnet-module

## Summary

Opinionated BDT-MSD wrapper around the **Azure Verified Module** for Virtual Network
([`Azure/avm-res-network-virtualnetwork/azurerm` v0.17.1](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest)).

Enforces BDT-MSD naming conventions (FDD §2.4), required tags (FDD Table 12),
hub-and-spoke peering patterns (FDD §2.3.6), and approved Azure regions (FDD §1.3 A2).

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

  enable_resource_lock = true   # recommended for prod

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

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.9.0, < 2.0.0 |
| hashicorp/azurerm | ~> 4.71 |
| Azure/azapi | ~> 2.9 |
| AVM VNet module | 0.17.1 |

> Versions confirmed via web search on 2026-05-06.
> Terraform latest: **1.15.1** · azurerm latest: **4.71.0** · azapi latest: **2.9.0**

---

## Inputs

| Name | Description | Type | Required | Default |
|---|---|---|---|---|
| `subscription_id` | Azure Subscription ID | `string` | yes | — |
| `resource_group_name` | Existing RG name. Pattern: `rg-*` (lowercase) | `string` | yes | — |
| `vnet_name` | VNet name. Pattern: `vnet-*` (lowercase) | `string` | yes | — |
| `location` | Azure region. Approved: `eastus2`, `centralus`, `eastus` | `string` | no | `eastus2` |
| `address_space` | List of CIDR blocks | `list(string)` | yes | — |
| `subnets` | Map of subnet objects | `map(object)` | no | `{}` |
| `hub_vnet_id` | Hub VNet resource ID for peering. Empty = no peering | `string` | no | `""` |
| `hub_vnet_name` | Hub VNet name (required if hub_vnet_id set) | `string` | no | `""` |
| `enable_resource_lock` | Apply CanNotDelete lock to VNet | `bool` | no | `false` |
| `log_analytics_workspace_id` | Log Analytics workspace ID for diagnostics | `string` | no | `""` |
| `tags` | Required BDT-MSD tags (Application, DevOwner, BusinessOwner, Environment, DataClassification, BusinessCriticality, IACRepository) | `map(string)` | yes | — |

---

## Outputs

| Name | Description | Type | Example |
|---|---|---|---|
| `vnet_id` | Resource ID of the VNet | `string` | `/subscriptions/.../virtualNetworks/...` |
| `vnet_name` | Name of the VNet | `string` | `vnet-myapp-prod-eus2-001` |
| `vnet_address_spaces` | Address spaces | `set(string)` | `["10.20.0.0/16"]` |
| `subnet_ids` | Map of subnet name → resource ID | `map(string)` | `{ "snet-app-prod-eus2-001" = "/..." }` |
| `subnet_address_prefixes` | Map of subnet name → address prefix | `map(string)` | `{ "snet-app-prod-eus2-001" = "10.20.1.0/24" }` |
| `peerings` | VNet peering info from AVM | `map(any)` | — |
| `resource` | Full AVM VNet resource object | `object` | — |

---

## Maintained by

| Name | Role | 
|---|---|---|
| Raghavendiran N | Senior DevOps Engineer |
| Sakthivel Manohar | Senior DevOps Engineer |
