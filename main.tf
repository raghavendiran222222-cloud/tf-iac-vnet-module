provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  name                 = var.vnet_name
  location             = var.location
  parent_id            = local.resource_group_id
  address_space        = toset(var.address_space)
  dns_servers          = local.dns_servers_config
  subnets              = local.avm_subnets
  peerings             = local.avm_peerings
  lock                 = local.lock_config
  diagnostic_settings  = local.diagnostic_settings
  ddos_protection_plan = local.ddos_protection_plan
  enable_telemetry     = false
  tags                 = local.merged_tags
}
