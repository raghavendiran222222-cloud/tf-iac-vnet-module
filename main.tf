provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  name          = var.vnet_name
  location      = var.location
  parent_id     = local.resource_group_id
  address_space = toset(var.address_space)

  subnets = local.avm_subnets

  peerings = local.avm_peerings

  lock = local.lock_config

  diagnostic_settings = local.diagnostic_settings

  enable_telemetry = false

  tags = local.merged_tags
}
