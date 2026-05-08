output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.vnet.resource_id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = module.vnet.name
}

output "vnet_address_spaces" {
  description = "List of address spaces of the Virtual Network."
  value       = tolist(var.address_space)
}

output "subnet_ids" {
  description = "Map of subnet name to subnet resource ID."
  value       = { for k, v in module.vnet.subnets : k => v.resource_id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet name to address prefix."
  value       = { for k, v in module.vnet.subnets : k => v.resource.address_prefixes[0] }
}

output "resource" {
  description = "Full AVM Virtual Network resource object."
  value       = module.vnet.resource
}
