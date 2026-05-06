module "spoke_vnet" {
  source = "git::https://github.com/bdtmsd/tf-iac-vnet-module.git?ref=v1.0.0"

  subscription_id     = "00000000-0000-0000-0000-000000000000"
  resource_group_name = "rg-bdt-terraform-dev-eus2-001"
  location            = "eastus2"
  vnet_name           = "vnet-tfwkst-dev-eus2-001"
  address_space       = ["10.10.0.0/16"]

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
    Application         = "TerraformWorkstation"
    DevOwner            = "raghavendirann@presidio.com"
    BusinessOwner       = "ogorelik@bdtmsd.com"
    Environment         = "dev"
    DataClassification  = "Sensitive"
    BusinessCriticality = "Medium"
    IACRepository       = "https://github.com/bdtmsd/tf-iac-vnet-module"
  }
}
