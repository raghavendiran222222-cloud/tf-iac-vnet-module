# tf-iac-vnet-module

An opinionated Terraform module for provisioning Azure Virtual Networks. Wraps the [Azure Verified Module (AVM)](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest) and provides a simplified, enterprise-ready interface for subnets, hub-spoke peering, resource locks, and diagnostic settings.

---

## Summary

```hcl
module "vnet" {
  source  = "git::https://github.com/your-org/tf-iac-vnet-module.git?ref=v1.0.0"

  subscription_id     = "00000000-0000-0000-0000-000000000000"
  resource_group_name = "rg-myapp-prod-eus2-001"
  vnet_name           = "vnet-myapp-prod-eus2-001"
  location            = "eastus2"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    "snet-app-prod-eus2-001" = {
      address_prefix    = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
  }

  enable_resource_lock = true

  tags = {
    Application = "MyApplication"
    Owner       = "platform-team@example.com"
    Environment = "prod"
    CostCenter  = "CC-1234"
  }
}
```

---

## Requirements

| Name       | Version              |
|-----------|----------------------|
| terraform  | `>= 1.9.0, < 2.0.0` |
| azurerm    | `~> 4.71`            |
| azapi      | `~> 2.9`             |

**AVM Dependency**: `Azure/avm-res-network-virtualnetwork/azurerm` `0.17.1`

---

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `subscription_id` | Azure Subscription ID | `string` | Yes | — |
| `resource_group_name` | Pre-existing Resource Group name | `string` | Yes | — |
| `vnet_name` | Virtual Network name | `string` | Yes | — |
| `location` | Azure region. Allowed: `eastus2`, `centralus`, `eastus`, `westus2`, `westeurope`, `northeurope` | `string` | No | `"eastus2"` |
| `address_space` | List of CIDR blocks for the VNet | `list(string)` | Yes | — |
| `tags` | Resource tags. Required keys: `Application`, `Owner`, `Environment`, `CostCenter` | `map(string)` | Yes | — |
| `subnets` | Map of subnet configs (see below) | `map(object)` | No | `{}` |
| `dns_servers` | Custom DNS server IPs | `list(string)` | No | `[]` |
| `ddos_protection_plan_id` | Resource ID of DDoS Protection Plan | `string` | No | `""` |
| `hub_vnet_id` | Resource ID of hub VNet for peering | `string` | No | `""` |
| `hub_vnet_name` | Name of hub VNet | `string` | No | `""` |
| `enable_resource_lock` | Apply CanNotDelete lock to VNet | `bool` | No | `false` |
| `log_analytics_workspace_id` | Log Analytics Workspace ID for diagnostics | `string` | No | `""` |

### Subnet Object Schema

```hcl
subnets = {
  "<subnet-name>" = {
    address_prefix    = string           # Required. CIDR block, e.g. "10.0.1.0/24"
    service_endpoints = list(string)     # Optional. e.g. ["Microsoft.Storage"]
    nsg_id            = string           # Optional. Resource ID of existing NSG
    route_table_id    = string           # Optional. Resource ID of existing Route Table
    delegation = {                       # Optional. Service delegation
      name    = string                   # Delegation name, e.g. "app-service-delegation"
      service = string                   # Service, e.g. "Microsoft.Web/serverFarms"
    }
  }
}
```

---

## Outputs

| Name | Description | Type |
|------|-------------|------|
| `vnet_id` | Resource ID of the Virtual Network | `string` |
| `vnet_name` | Name of the Virtual Network | `string` |
| `vnet_address_spaces` | Address spaces of the VNet | `list(string)` |
| `subnet_ids` | Map of subnet name → subnet resource ID | `map(string)` |
| `subnet_address_prefixes` | Map of subnet name → CIDR prefix | `map(string)` |
| `resource` | Full AVM VNet resource object | `object` |

---

## Usage Examples

### Basic Spoke VNet

```hcl
module "spoke_vnet" {
  source = "git::https://github.com/your-org/tf-iac-vnet-module.git?ref=v1.0.0"

  subscription_id     = var.subscription_id
  resource_group_name = "rg-myapp-dev-eus2-001"
  vnet_name           = "vnet-myapp-dev-eus2-001"
  address_space       = ["10.10.0.0/16"]

  subnets = {
    "snet-app-dev-eus2-001" = {
      address_prefix    = "10.10.1.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "snet-data-dev-eus2-001" = {
      address_prefix = "10.10.2.0/24"
      service_endpoints = ["Microsoft.Sql"]
    }
  }

  tags = {
    Application = "MyApp"
    Owner       = "team@example.com"
    Environment = "dev"
    CostCenter  = "CC-5678"
  }
}
```

### Hub-Spoke Peering

```hcl
module "spoke_vnet" {
  source = "git::https://github.com/your-org/tf-iac-vnet-module.git?ref=v1.0.0"

  subscription_id     = var.subscription_id
  resource_group_name = "rg-myapp-prod-eus2-001"
  vnet_name           = "vnet-myapp-prod-eus2-001"
  address_space       = ["10.20.0.0/16"]

  hub_vnet_id   = "/subscriptions/.../resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod-eus2-001"
  hub_vnet_name = "vnet-hub-prod-eus2-001"

  enable_resource_lock = true
  log_analytics_workspace_id = "/subscriptions/.../resourceGroups/rg-shared/providers/Microsoft.OperationalInsights/workspaces/law-shared-prod"

  subnets = {
    "snet-app-prod-eus2-001" = {
      address_prefix = "10.20.1.0/24"
    }
  }

  tags = {
    Application = "MyApp"
    Owner       = "team@example.com"
    Environment = "prod"
    CostCenter  = "CC-5678"
  }
}
```

---

## Versioning

This module follows [Semantic Versioning 2.0.0](https://semver.org/). Pin to a specific release tag:

```hcl
source = "git::https://github.com/your-org/tf-iac-vnet-module.git?ref=v1.0.0"
```

See [CHANGELOG.MD](./CHANGELOG.MD) for release notes.

---

## Maintained By

| Role | Contact |
|------|---------|
| Platform Engineering | platform-team@example.com |
