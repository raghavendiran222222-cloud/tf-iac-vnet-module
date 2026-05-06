
output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.vnet.resource_id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = module.vnet.name
}

output "vnet_address_spaces" {
  description = "Address spaces of the Virtual Network."
  value       = module.vnet.address_spaces
}

output "subnet_ids" {
  description = "Map of subnet name to subnet resource ID."
  value       = { for k, v in module.vnet.subnets : k => v.resource_id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet name to address prefix."
  value = {
    for k, v in module.vnet.subnets : k => v.resource.address_prefixes[0]
    if v.resource != null
  }
}

output "peerings" {
  description = "VNet peering information from the AVM module."
  value       = module.vnet.peerings
}

output "resource" {
  description = "Full AVM VNet resource object. Use for advanced attribute access."
  value       = module.vnet.resource
  sensitive   = false
}
