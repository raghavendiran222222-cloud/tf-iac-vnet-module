module "spoke_vnet" {
  source = "../../"

  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  location            = var.location
  address_space       = var.address_space

  subnets = {
    "snet-app-dev-eus2-001" = {
      address_prefix    = "10.10.1.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "snet-data-dev-eus2-001" = {
      address_prefix    = "10.10.2.0/24"
      service_endpoints = ["Microsoft.Sql"]
    }
  }

  enable_resource_lock = false

  tags = {
    Application = "MyApplication"
    Owner       = "platform-team@example.com"
    Environment = "dev"
    CostCenter  = "CC-1234"
  }
}
